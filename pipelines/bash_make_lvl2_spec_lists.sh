#!/bin/bash
#
# STUDY SPECIFIC SCRIPT called by spm_eval_stats_lists.sh to setup text lists  
# using shell script. Text lists are used as input to spm_lvl2_spec.sh.
#
# Usage: bash_make_lvl2_spec_lists FACTOR_LIST FACTOR_LEVELS_LIST FACTOR_DEP_LIST FACTOR_VAR_LIST CELL_LEVELS_LIST CELL_CON_FILES_LIST
#
# FACTOR_LIST - Fullpath to text file listing factor names, 1 factor per row.
# FACTOR_LEVELS_LIST - Fullpath to text file listing factor number of levels, 1 number per row.
# FACTOR_DEP_LIST - Fullpath to text file listing factor dependency (1: Dep, 0: Indep), 1 number per row.
# FACTOR_VAR_LIST - Fullpath to text file listing factor variance assumption (1: Uneq, 0: Eq), 1 number per row.
# CELL_LEVELS_LIST - Fullpath to text file listing cell level vectors, 1 double vector per row.
# CELL_CON_FILES_LIST - Fullpath to text file listing text files that list cell contrast *.nii, 1 filename fullpath per row (per cell).
# 
# 20251120 Created by Josh Goh.

# Assign parameters
FACTOR_LIST=${1}
FACTOR_LEVELS_LIST=${2}
FACTOR_DEP_LIST=${3}
FACTOR_VAR_LIST=${4}
CELL_LEVELS_LIST=${5}
CELL_CON_FILES_LIST=${6}

FACTOR_NAME=("REP" "AGE")
FACTOR_LEVELS=("3" "2")
FACTOR_DEP=("1" "0")
FACTOR_VAR=("0" "1")
CELL_LEVELS=("1 1" "2 1" "3 1" "1 2" "2 2" "3 2")
CELL_CON_LEVELS=("con_0001" "con_0002" "con_0003" "con_0001" "con_0002" "con_0003")
CELL_GRP_LEVELS=("y" "y" "y" "o" "o" "o")

for (( F=0; F<${#FACTOR_NAME[@]}; F++ )); do
    echo "${FACTOR_NAME[F]}"   >> "${FACTOR_LIST}"
    echo "${FACTOR_LEVELS[F]}" >> "${FACTOR_LEVELS_LIST}"
    echo "${FACTOR_DEP[F]}"    >> "${FACTOR_DEP_LIST}"
    echo "${FACTOR_VAR[F]}"    >> "${FACTOR_VAR_LIST}"
    
done

for (( C=0; C<${#CELL_LEVELS[@]}; C++ )); do
	echo "${CELL_LEVELS[C]}" >> ${CELL_LEVELS_LIST}
	echo "CELL_${C}_CON_LIST.txt" >> ${CELL_CON_FILES_LIST}
	for dir_path in ~/projects/REP/data/derivatives/${CELL_GRP_LEVELS[C]}*; do
        	echo "${dir_path}/results/${CELL_CON_LEVELS[C]}.nii"
    	done > "CELL_${C}_CON_LIST.txt"
done
