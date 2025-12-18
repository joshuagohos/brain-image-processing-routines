#!/bin/bash
# Convert source dicom to nii, move to raw, copy to derivatives.
# - Created by Josh Goh 20251030

PROJECT_DIR=/home/joshgoh/projects/REP
DATA_ARR=("y01" "y02")
#DATA_ARR=$(ls -1 ${PROJECT_DIR}/data/sourcedata/)
DERIVATIVES_DIR=${PROJECT_DIR}/data/derivatives/testbed

mkdir -p ${DERIVATIVES_DIR}
for subj in "${DATA_ARR[@]}"; do
	mkdir -p ${PROJECT_DIR}/data/rawdata/$subj/nii/
	dcm2niix -o ${PROJECT_DIR}/data/rawdata/$subj/nii/ ${PROJECT_DIR}/data/sourcedata/${subj}
	cp -rf ${PROJECT_DIR}/data/rawdata/$subj ${DERIVATIVES_DIR}/
done
echo "Dicom conversion done!"
