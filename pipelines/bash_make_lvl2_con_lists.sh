#!/bin/bash
#
# STUDY SPECIFIC SCRIPT called by spm_eval_stats_lists.sh to setup CONTYPE, CONNAME, CONVEC text lists  
# using shell script. Text lists are used as input to spm_stats_con.sh.
#
# Usage: bash_make_lvl2_con_lists CONTYPE_LIST CONNAME_LIST CONVEC_LIST
#
# CONTYPE_LIST - Fullpath to CONTYPE_LIST.txt for writing contrast type.
# CONNAME_LIST - Fullpath to CONNAME_LIST.txt for writing contrast names.
# CONVEC_LIST - Fullpath to CONVEC_LIST.txt for writing contrast vectors.
# 
# 20251120 Created by Josh Goh.

# Assign parameters
CONTYPE_LIST=${1}
CONNAME_LIST=${2}
CONVEC_LIST=${3}

CONTYPE=("T" "F")
CONNAME=("Y_P31" \
         "-Y_P31" \
         "Y_P32" \
         "-Y_P32" \
         "Y_P33" \
         "-Y_P33" \
         "O_P31" \
         "-O_P31" \
         "O_P32" \
         "-O_P32" \
         "O_P33" \
         "-O_P33" \
         "Y_P31-Y_P32" \
         "Y_P32-Y_P31" \
         "Y_P31-Y_P33" \
         "Y_P33-Y_P31" \
         "Y_P32-Y_P33" \
         "Y_P33-Y_P32" \
         "O_P31-O_P32" \
         "O_P32-O_P31" \
         "O_P31-O_P33" \
         "O_P33-O_P31" \
         "O_P32-O_P33" \
         "O_P33-O_P32" \
         "Y" \
         "-Y" \
         "O" \
         "-O" \
         "Y-O" \
         "O-Y" \
         "Y_P31-O_P31" \
         "O_P31-Y_P31" \
         "Y_P32-O_P32" \
         "O_P32-Y_P32" \
         "Y_P33-O_P33" \
         "O_P33-Y_P33" \
         "(Y_P31-Y_P32)-(O_P31-O_P32)" \
         "(O_P31-O_P32)-(Y_P31-Y_P32)" \
         "(Y_P31-Y_P33)-(O_P31-O_P33)" \
         "(O_P31-O_P33)-(Y_P31-Y_P33)" \
         "(Y_P32-Y_P33)-(O_P32-O_P33)" \
         "(O_P32-O_P33)-(Y_P32-Y_P33)")
CONVEC=("1 0 0 0 0 0" \
	"-1 0 0 0 0 0" \
	"0 0 1 0 0 0" \
	"0 0 -1 0 0 0" \
	"0 0 0 0 1 0" \
	"0 0 0 0 -1 0" \
	"0 1 0 0 0 0" \
	"0 -1 0 0 0 0" \
	"0 0 0 1 0 0" \
	"0 0 0 -1 0 0" \
	"0 0 0 0 1 0" \
	"0 0 0 0 -1 0" \
	"1 0 -1 0 0 0" \
	"-1 0 1 0 0 0" \
	"1 0 0 0 -1 0" \
	"-1 0 0 0 1 0" \
	"0 0 1 0 -1 0" \
	"0 0 -1 0 1 0" \
	"0 1 0 -1 0 0" \
	"0 -1 0 1 0 0" \
	"0 1 0 0 0 -1" \
	"0 -1 0 0 0 1" \
	"0 0 0 1 0 -1" \
	"0 0 0 -1 0 1" \
	"1 0 1 0 1 0" \
	"-1 0 -1 0 -1 0" \
	"0 1 0 1 0 1" \
	"0 -1 0 -1 0 -1" \
	"1 -1 1 -1 1 -1" \
	"-1 1 -1 1 -1 1" \
	"1 -1 0 0 0 0" \
	"-1 1 0 0 0 0" \
	"0 0 1 -1 0 0" \
	"0 0 -1 1 0 0" \
	"0 0 0 0 1 -1" \
	"0 0 0 0 -1 1" \
	"1 -1 -1 1 0 0" \
	"-1 1 1 -1 0 0" \
	"1 -1 0 0 -1 1" \
	"-1 1 0 0 1 -1" \
	"0 0 1 -1 -1 1" \
	"0 0 -1 1 1 -1")

for (( C=0; C<${#CONNAME[@]}; C++ )); do
    echo "${CONTYPE[0]}" >> "${CONTYPE_LIST}"
    echo "${CONNAME[C]}" >> "${CONNAME_LIST}"
    echo "${CONVEC[C]}" >> "${CONVEC_LIST}"
done
