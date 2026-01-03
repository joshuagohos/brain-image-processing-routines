#!/bin/bash

# SET PATHS, DATA, PARAMETERS AND GLOBS
CURR_DIR=$(pwd)
PROJECT_DIR=/home/joshgoh/projects/REP
DERIVATIVES_DIR=${PROJECT_DIR}/data/derivatives_fc
SEL_DATA_ARR=("o01")
DATA_ARR_FULLPATH=(${PROJECT_DIR}/data/sourcedata/*)
EPI_FILENAME_GLOB=*REP*
T1_FILENAME_GLOB=*T1*.nii
T2_FILENAME_GLOB=*t2*.nii
UNWANTED_FILENAME_GLOBS=("*REP*MoCo*.*")
STUDY_SPECIFIC_OTHER_CLEANUP_SCRIPT=${PROJECT_DIR}/code/pipelines/specs/spm_pipeline_other_cleanup.sh
REALIGN_TO_MEAN=1 # 1: Register to first
SLICE_TIME_SLICE_ORDER="eval('[2:2:nslices,1:2:nslices]')"
SLICE_TIME_REF_SLICE=2 # If SLICE_TIME_SLICE_ORDER is in ms, then this is in ms.
SLICE_TIME_TIME_ACQUISITION="eval('tr-(tr/nslices)')" # If SLICE_TIME_SLICE_ORDER is in ms, then this is 0.
SLICE_TO_SLICE="eval('tr/nslices')"
COREG_OTHER=0
SEGMENT_AFF_REG=mni # Alt: mni | eastern | subj | none | 0 
DENOISE_MASK_THRESHOLD=0.95
NORM_RESAMPLING=3,3,3
SMOOTH_KERNEL=8,8,8
rc_GLOBS=("rc1" "rc2" "rc3" "rc4" "rc5" "rc6")
#LVL1_EPI_INPUT_PREFIX=swar
LVL1_EPI_INPUT_PREFIX=ar
LVL1_REGLIST_GLOB=rp*.txt
LVL1_DENOISE_REGLIST_GLOB=multiple_regressors_epi*.txt
LVL1_STATS_UNITS=secs
LVL1_STATS_TR=2
LVL1_STATS_MICROTIME_RES=32
LVL1_STATS_MICROTIME_ONSET=2
LVL1_MASK_THRESH=0.8
LVL1_MASK=""
LVL1_STATS_RESIDUALS=1 # 1: Save, 0: Do not save 
LVL1_STATS_DELETE_CONS=1 # 1: Delete, 0: Do not delete 
STUDY_SPECIFIC_MAKE_LVL1_CON_LIST_SCRIPT=${PROJECT_DIR}/code/pipelines/specs/spm_make_lvl1_con_lists.sh # Be sure to check this file
STUDY_SPECIFIC_MAKE_LVL2_SPEC_LIST_SCRIPT=${PROJECT_DIR}/code/pipelines/specs/bash_make_spm_lvl2_spec_lists.sh # Be sure to check this file
STUDY_SPECIFIC_MAKE_LVL2_CON_LIST_SCRIPT=${PROJECT_DIR}/code/pipelines/specs/bash_make_spm_lvl2_con_lists.sh # Be sure to check this file
GROUP_NAME=group
LVL2_STATS_RESIDUALS=0 # 1: Save, 0: Do not save
LVL2_STATS_DELETE_CONS=1 # 1: Delete, 0: Do not delete

# SELECT ROUTINES
SUBJ_LEVEL_PREPROC="yes"
DICOM2NII="no"
COPY_RAW2DERIVATIVES="no"
FILE_CLEANUP="no"
REALIGN_RESLICE="no"
SLICE_TIME_CORRECTION="no"
COREG_T2_EPI="no"
COREG_T1_T2="no"
SEGMENT_T1="no"
DENOISE_EPI="yes"
NORMALISE_EPI_MNI="no"
SMOOTH_EPI="no"

GROUP_LEVEL_PREPROC="no"
MAKE_SST="no"
NORMALISE_EPI_SST_MNI="no"
NORMALISE_T1_SST_MNI="no"

SUBJ_LEVEL_STATS="no"
LVL1_SPEC="yes"
LVL1_EST="yes"
LVL1_CON="no"

GROUP_LEVEL_STATS="no"
LVL2_SPEC="no"
LVL2_EST="no"
LVL2_CON="no"

# Initiate derivatives directory
mkdir -p ${DERIVATIVES_DIR}

# SUBJECT LEVEL PREPROCESSING
if [[ "$SUBJ_LEVEL_PREPROC" == "yes" ]]; then

	# Set DATA_ARR
	if [[ "${SEL_DATA_ARR[@]}" == "" ]]; then
		TEMP=( "${DATA_ARR_FULLPATH[@]##*/}" )
		DATA_ARR=( "${TEMP[@]%/}" )
	else
		DATA_ARR=( "${SEL_DATA_ARR[@]}" )
	fi

	# Loop through subject directories
	for subj in "${DATA_ARR[@]}"; do

		echo "Working on ${subj}"

		# Convert dicom to raw.
		if [[ "${DICOM2NII}" == "yes" ]]; then
			echo "Working on ${subj} DICOM conversion."
			mkdir -p ${PROJECT_DIR}/data/rawdata/$subj/nii/
			dcm2niix -o ${PROJECT_DIR}/data/rawdata/$subj/nii/ ${PROJECT_DIR}/data/sourcedata/${subj}
			echo "${subj} DICOM conversion done."
		fi

		# Copy to derivatives
		if [[ "${COPY_RAW2DERIVATIVES}" == "yes" ]]; then
			cp -rf ${PROJECT_DIR}/data/rawdata/$subj ${DERIVATIVES_DIR}/
			echo "${subj} NIfTI files copied to derivatives directory."
		fi

		# Check and/or cleanup unwanted files
		if [[ "${FILE_CLEANUP}" == "yes" ]]; then
			echo "Working on ${subj} unwanted file checking and removal."
			for file in "${UNWANTED_FILENAME_GLOBS[@]}"; do
				rm -rf ${DERIVATIVES_DIR}/${subj}/nii/${file}
			done
			bash "${STUDY_SPECIFIC_OTHER_CLEANUP_SCRIPT}"
			echo "${subj} unwanted files removed. Now is a good time to check your remaining files first"
			EPI_FILES=( ${DERIVATIVES_DIR}/${subj}/nii/${EPI_FILENAME_GLOB}.nii ) 
			for (( file=0; file<${#EPI_FILES[@]}; file++ )); do
				echo ${EPI_FILES[${file}]} >> ${PROJECT_DIR}/code/pipelines/specs/EPI_${file}_DATA_LIST.txt
			done
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/${T2_FILENAME_GLOB} >> ${PROJECT_DIR}/code/pipelines/specs/T2_DATA_LIST.txt
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/${T1_FILENAME_GLOB} >> ${PROJECT_DIR}/code/pipelines/specs/T1_DATA_LIST.txt
			echo "List of files updated in project code directory."
		fi

		# Enter subject level directory
		cd ${DERIVATIVES_DIR}/${subj}/nii
		EPI_DATA_LIST=${DERIVATIVES_DIR}/${subj}/nii/EPI_DATA_LIST.txt

		# Realign and reslice EPI files
		if [[ "${REALIGN_RESLICE}" == "yes" ]]; then
			echo "Working on ${subj} realignment and reslicing."
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/${EPI_FILENAME_GLOB}.nii >> ${EPI_DATA_LIST}
			spm_realign_reslice ${EPI_DATA_LIST} ${REALIGN_TO_MEAN} ${subj}_spm_realign_reslice 1
			rm -rf ${EPI_DATA_LIST}
			echo "${subj} realign and reslice done."
		fi

		# Slice-time correct realigned-resliced EPI files
		if [[ "${SLICE_TIME_CORRECTION}" == "yes" ]]; then
			echo "Working on ${subj} slice time correction."
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/r${EPI_FILENAME_GLOB}.nii >> ${EPI_DATA_LIST}
			spm_slice-timing ${EPI_DATA_LIST} ${SLICE_TIME_REF_SLICE} ${SLICE_TIME_SLICE_ORDER} ${SLICE_TIME_TIME_ACQUISITION} ${subj}_spm_slice-timing 1
			rm -rf ${EPI_DATA_LIST}
			echo "${subj} slice time correction done."
		fi

		# Coregister T2 to EPI
		if [[ "${COREG_T2_EPI}" == "yes" ]]; then
			echo "Working on ${subj} T2 to EPI coregistration."
			arEPI_DATA_VOL=$(ls -1 ${DERIVATIVES_DIR}/${subj}/nii/ar${EPI_FILENAME_GLOB}.nii | sed -n '1p')
			T2_DATA_VOL=$(ls -1 ${DERIVATIVES_DIR}/${subj}/nii/${T2_FILENAME_GLOB})
			spm_coreg ${arEPI_DATA_VOL} ${T2_DATA_VOL} ${COREG_OTHER} ${subj}_spm_coreg_T2-EPI 1
			echo "${subj} T2 to EPI coregistration done."
		fi

		# Coregister T1 to EPI-coregistered T2
		if [[ "${COREG_T1_T2}" == "yes" ]]; then
			echo "Working on ${subj} T1 to EPI-coregistered T2 coregistration."
			T1_DATA_VOL=$(ls -1 ${DERIVATIVES_DIR}/${subj}/nii/${T1_FILENAME_GLOB})
			spm_coreg ${T2_DATA_VOL} ${T1_DATA_VOL} ${COREG_OTHER} ${subj}_spm_coreg_T1-T2 1
			echo "${subj} T1 to EPI-coregistered T2 coregistration done."
		fi

		# Segment T2-EPI-coregistered T1
		if [[ "${SEGMENT_T1}" == "yes" ]]; then
			echo "Working on ${subj} T1 segmentation."
			spm_segment ${T1_DATA_VOL} ${SEGMENT_AFF_REG} ${subj}_spm_segment 1
			echo "${subj} T1 segmentation done."
		fi

		# Extract denoising physiological parameters (runs PhysIO module)
		if [[ "${DENOISE_EPI}" == "yes" ]]; then
			echo "Working on ${subj} EPI denoising parameter extraction."
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/ar${EPI_FILENAME_GLOB}.nii >> ${EPI_DATA_LIST}
			WM_MASK=${DERIVATIVES_DIR}/$subj/nii/c2*.nii
			CSF_MASK=${DERIVATIVES_DIR}/$subj/nii/c3*.nii
			REG_LIST=${DERIVATIVES_DIR}/${subj}/nii/REG_LIST.txt
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/${LVL1_REGLIST_GLOB} >> ${REG_LIST}
			spm_denoise_physio ${DERIVATIVES_DIR}/${subj}/nii ${EPI_DATA_LIST} ${LVL1_STATS_TR} ${SLICE_TIME_REF_SLICE} ${SLICE_TO_SLICE} ${WM_MASK} ${CSF_MASK} ${DENOISE_MASK_THRESHOLD} ${REG_LIST} ${subj}_spm_denoise_EPI
			rm -rf ${EPI_DATA_LIST} ${REG_LIST}
			echo "${subj} EPI denoising parameter extraction done."
		fi

		# Normalise EPI to MNI
		if [[ "${NORMALISE_EPI_MNI}" == "yes" ]]; then
			echo "Working on ${subj} EPI normalisation to MNI."
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/ar${EPI_FILENAME_GLOB}.nii >> ${EPI_DATA_LIST}
			DEF_FIELD_VOL=$(ls -1 ${DERIVATIVES_DIR}/${subj}/nii/y_*.nii)
			spm_normalise_write ${EPI_DATA_LIST} ${DEF_FIELD_VOL} ${NORM_RESAMPLING} ${subj}_spm_normalise 1
			rm -rf ${EPI_DATA_LIST}
			echo "${subj} EPI normalisation to MNI done."
		fi

		# Smooth EPI
		if [[ "${SMOOTH_EPI}" == "yes" ]]; then
			echo "Working on ${subj} EPI spatial smoothing."
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/war${EPI_FILENAME_GLOB}.nii >> ${EPI_DATA_LIST}
			spm_smooth ${EPI_DATA_LIST} ${SMOOTH_KERNEL} ${subj}_spm_smooth 1
			rm -rf ${EPI_DATA_LIST}
			echo "${subj} EPI spatial smoothing done."
		fi

		echo "${subj} preprocessing done."
	done
fi

# GROUP LEVEL PREPROCESSING
if [[ "$GROUP_LEVEL_PREPROC" == "yes" ]]; then

	echo "Working on group level"

	# Set DATA_ARR
	TEMP=( "${DATA_ARR_FULLPATH[@]##*/}" )
	DATA_ARR=( "${TEMP[@]%/}" )

	if [[ "${MAKE_SST}" == "yes" ]]; then

		# Make SST
		echo "Working on SST"
		mkdir -p ${DERIVATIVES_DIR}/SST
		cd ${DERIVATIVES_DIR}/SST
		rm -rf rc_DATA_LIST.txt
		for IMAGE in "${rc_GLOBS[@]}"; do
			rm -rf ${IMAGE}_LIST.txt
			for subj in "${DATA_ARR[@]}"; do
				ls -1 ${DERIVATIVES_DIR}/$subj/nii/$IMAGE*.nii >> ${IMAGE}_LIST.txt
			done
			echo "${IMAGE}_LIST.txt" >> rc_DATA_LIST.txt
		done
		spm_make_SST rc_DATA_LIST.txt spm_make_SST 1
		read -r FIRST_SUBJ_FULLFILE < rc1_LIST.txt
		FIRST_SUBJ_DIR=${FIRST_SUBJ_FULLFILE%/*}
		mv ${FIRST_SUBJ_DIR}/Template_*.nii ${DERIVATIVES_DIR}/SST/
		rm -rf rc_DATA_LIST.txt rc*_LIST.txt
		echo "SST done."
	fi

	if [[ ${NORMALISE_EPI_SST_MNI} == "yes" ]]; then

		# Normalise EPI to SST then to MNI and smooth
		echo "Working on EPI to SST to MNI normalisation and smoothing"
		rm -rf ${DERIVATIVES_DIR}/SST/FLOW_FIELD_LIST.txt
		rm -rf ${DERIVATIVES_DIR}/SST/IMAGE_FILE_LIST.txt
		for subj in "${DATA_ARR[@]}"; do
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/u_*.nii >> ${DERIVATIVES_DIR}/SST/FLOW_FIELD_LIST.txt
			IMAGE_FILES=(${DERIVATIVES_DIR}/${subj}/nii/ar${EPI_FILENAME_GLOB}.nii)
			echo ${IMAGE_FILES[*]} >> ${DERIVATIVES_DIR}/SST/IMAGE_FILE_LIST.txt
		done
		spm_normalise-sst-mni ${DERIVATIVES_DIR}/SST/Template_6.nii ${DERIVATIVES_DIR}/SST/FLOW_FIELD_LIST.txt ${DERIVATIVES_DIR}/SST/IMAGE_FILE_LIST.txt ${NORM_RESAMPLING} ${SMOOTH_KERNEL} ${DERIVATIVES_DIR}/SST/spm_normalise_epi_sst-mni 1
		rm -rf ${DERIVATIVES_DIR}/SST/FLOW_FIELD_LIST.txt ${DERIVATIVES_DIR}/SST/IMAGE_FILE_LIST.txt
		echo "EPI to SST to MNI normalisation and smoothing done"
	fi

	if [[ ${NORMALISE_T1_SST_MNI} == "yes" ]]; then

		# Normalise T1 to SST then to MNI
		echo "Working on T1 to SST to MNI normalisation"
		rm -rf ${DERIVATIVES_DIR}/SST/FLOW_FIELD_LIST.txt
		rm -rf ${DERIVATIVES_DIR}/SST/T1_IMAGE_FILE_LIST.txt
		for subj in "${DATA_ARR[@]}"; do
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/u_*.nii >> ${DERIVATIVES_DIR}/SST/FLOW_FIELD_LIST.txt
			ls ${PROJECT_DIR}/data/rawdata/${subj}/nii/${T1_FILENAME_GLOB} | sed 's/rawdata/derivatives/' >> ${DERIVATIVES_DIR}/SST/T1_IMAGE_FILE_LIST.txt
		done
		spm_normalise-sst-mni ${DERIVATIVES_DIR}/SST/Template_6.nii ${DERIVATIVES_DIR}/SST/FLOW_FIELD_LIST.txt ${DERIVATIVES_DIR}/SST/T1_IMAGE_FILE_LIST.txt NaN,NaN,NaN 0,0,0 ${DERIVATIVES_DIR}/SST/spm_normalise_T1_sst-mni 1
		rm -rf ${DERIVATIVES_DIR}/SST/FLOW_FIELD_LIST.txt ${DERIVATIVES_DIR}/SST/T1_IMAGE_FILE_LIST.txt
		echo "T1 to SST to MNI normalisation done"
	fi

fi

# SUBJECT LEVEL STATISTICS
if [[ "$SUBJ_LEVEL_STATS" == "yes" ]]; then

	# Set DATA_ARR
	if [[ "${SEL_DATA_ARR}" == "" ]]; then
		TEMP=( "${DATA_ARR_FULLPATH[@]##*/}" )
		DATA_ARR=( "${TEMP[@]%/}" )
	else
		DATA_ARR=( "${SEL_DATA_ARR[@]}" )
	fi

	# Loop through subject directories
	for subj in "${DATA_ARR[@]}"; do

		RESULTS_DIR=${DERIVATIVES_DIR}/${subj}/results
		mkdir -p ${RESULTS_DIR}
		cd ${RESULTS_DIR}

		# LEVEL 1 SPECIFICATION
		if [[ ${LVL1_SPEC} == "yes" ]]; then

			echo "Working on ${subj} level 1 stats specification."
			EPI_DATA_LIST=${DERIVATIVES_DIR}/${subj}/nii/EPI_DATA_LIST.txt
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/${LVL1_EPI_INPUT_PREFIX}${EPI_FILENAME_GLOB}.nii >> ${EPI_DATA_LIST}
			SOA_LIST=${DERIVATIVES_DIR}/${subj}/nii/SOA_LIST.txt
			ls -1 ${PROJECT_DIR}/data/sourcedata/${subj}/beh/*_soa.mat >> ${SOA_LIST}
			REG_LIST=${DERIVATIVES_DIR}/${subj}/nii/REG_LIST.txt
			ls -1 ${DERIVATIVES_DIR}/${subj}/nii/${LVL1_REGLIST_GLOB} >> ${REG_LIST}
			spm_lvl1_spec ${EPI_DATA_LIST} ${SOA_LIST} ${REG_LIST} ${RESULTS_DIR} ${LVL1_STATS_UNITS} ${LVL1_STATS_TR} ${LVL1_STATS_MICROTIME_RES} ${LVL1_STATS_MICROTIME_ONSET} "${LVL1_MASK}" ${LVL1_MASK_THRESH} ${subj}_spm_lvl1_spec 1
			rm -rf ${EPI_DATA_LIST} ${SOA_LIST} ${REG_LIST}
			echo "${subj} level 1 specification done."
		fi

		# LEVEL 1 ESTIMATION
		if [[ ${LVL1_EST} == "yes" ]]; then

			echo "Working on ${subj} level 1 stats estimation."
			spm_stats_est ${RESULTS_DIR}/SPM.mat ${LVL1_STATS_RESIDUALS} ${subj}_spm_lvl1_est 1
			echo "${subj} level 1 estimation done."
		fi

		# LEVEL 1 CONTRAST
		if [[ ${LVL1_CON} == "yes" ]]; then

			echo "Working on ${subj} level 1 stats contrasts."
			SOA_LIST=${RESULTS_DIR}/SOA_LIST.txt
			CONTYPE_LIST=${RESULTS_DIR}/CONTYPE_LIST.txt
			CONNAME_LIST=${RESULTS_DIR}/CONNAMES_LIST.txt
			CONVEC_LIST=${RESULTS_DIR}/CONVEC_LIST.txt
			rm -rf ${SOA_LIST} ${CONTYPE_LIST} ${CONVEC_LIST} ${CONNAME_LIST} ${CONVEC_LIST}
			ls -1 ${PROJECT_DIR}/data/sourcedata/${subj}/beh/*_soa.mat >> ${SOA_LIST}
			spm_eval_stats_lists ${STUDY_SPECIFIC_MAKE_LVL1_CON_LIST_SCRIPT} ${SOA_LIST} ${CONTYPE_LIST} ${CONNAME_LIST} ${CONVEC_LIST}
			spm_stats_con ${RESULTS_DIR}/SPM.mat ${CONTYPE_LIST} ${CONNAME_LIST} ${CONVEC_LIST} ${LVL1_STATS_DELETE_CONS} ${subj}_spm_lvl1_con 1
			rm -rf ${SOA_LIST} ${CONTYPE_LIST} ${CONVEC_LIST} ${CONNAME_LIST} ${CONVEC_LIST}
			echo "${subj} level 1 contrasts done."
		fi

		# MERGE RESIDUALS

		# DETREND

		# BANDPASS FILTER

	done
fi

# GROUP LEVEL STATISTICS
if [[ "$GROUP_LEVEL_STATS" == "yes" ]]; then

	GRP_RESULTS_DIR=${DERIVATIVES_DIR}/group_results
	mkdir -p ${GRP_RESULTS_DIR}
	cd ${GRP_RESULTS_DIR}

	# LEVEL 2 SPECIFICATION (FULL FACTORIAL)
	if [[ ${LVL2_SPEC} == "yes" ]]; then
		echo "Working on level 2 stats specification (full factorial)."
		FACTOR_LIST=${GRP_RESULTS_DIR}/FACTOR_LIST.txt
		FACTOR_LEVELS_LIST=${GRP_RESULTS_DIR}/FACTOR_LEVELS_LIST.txt
		FACTOR_DEP_LIST=${GRP_RESULTS_DIR}/FACTOR_DEP_LIST.txt
		FACTOR_VAR_LIST=${GRP_RESULTS_DIR}/FACTOR_VAR_LIST.txt
		CELL_LEVELS_LIST=${GRP_RESULTS_DIR}/CELL_LEVELS_LIST.txt
		CELL_CON_FILES_LIST=${GRP_RESULTS_DIR}/CELL_CON_FILES_LIST.txt
		rm -rf ${FACTOR_LIST} ${FACTOR_LEVELS_LIST} ${FACTOR_DEP_LIST} ${FACTOR_VAR_LIST} ${CELL_LEVELS_LIST} ${CELL_CON_FILES_LIST}
		spm_eval_stats_lists ${STUDY_SPECIFIC_MAKE_LVL2_SPEC_LIST_SCRIPT} ${FACTOR_LIST} ${FACTOR_LEVELS_LIST} ${FACTOR_DEP_LIST} ${FACTOR_VAR_LIST} ${CELL_LEVELS_LIST} ${CELL_CON_FILES_LIST} 
		spm_lvl2_spec ${GRP_RESULTS_DIR} ${FACTOR_LIST} ${FACTOR_LEVELS_LIST} ${FACTOR_DEP_LIST} ${FACTOR_VAR_LIST} ${CELL_LEVELS_LIST} ${CELL_CON_FILES_LIST} ${GROUP_NAME}_spm_lvl2_spec 0
		rm -rf ${FACTOR_LIST} ${FACTOR_LEVELS_LIST} ${FACTOR_DEP_LIST} ${FACTOR_VAR_LIST} ${CELL_LEVELS_LIST} ${CELL_CON_FILES_LIST}
		echo "Group level full factorial specification done."
	fi

	# LEVEL 2 ESTIMATION
	if [[ ${LVL2_EST} == "yes" ]]; then

		echo "Working on level 2 stats estimation."
		spm_stats_est ${GRP_RESULTS_DIR}/SPM.mat ${LVL2_STATS_RESIDUALS} ${GROUP_NAME}_spm_lvl2_est 0
		echo "${subj} level 2 estimation done."
	fi

	# LEVEL 2 CONTRAST
	if [[ ${LVL2_CON} == "yes" ]]; then

		echo "Working on level 2 stats contrats."
		CONTYPE_LIST=${GRP_RESULTS_DIR}/CONTYPE_LIST.txt
		CONNAME_LIST=${GRP_RESULTS_DIR}/CONNAMES_LIST.txt
		CONVEC_LIST=${GRP_RESULTS_DIR}/CONVEC_LIST.txt
		rm -rf ${CONTYPE_LIST} ${CONVEC_LIST} ${CONNAME_LIST} ${CONVEC_LIST}
		spm_eval_stats_lists ${STUDY_SPECIFIC_MAKE_LVL2_CON_LIST_SCRIPT} ${CONTYPE_LIST} ${CONNAME_LIST} ${CONVEC_LIST}
		spm_stats_con ${GRP_RESULTS_DIR}/SPM.mat ${CONTYPE_LIST} ${CONNAME_LIST} ${CONVEC_LIST} ${LVL2_STATS_DELETE_CONS} ${GROUP_NAME}_spm_lvl2_con 0
		rm -rf ${CONTYPE_LIST} ${CONNAME_LIST} ${CONVEC_LIST}
		echo "${subj} level 2 contrasts done."

	fi

fi

cd ${CURR_DIR}
echo "Done!"

