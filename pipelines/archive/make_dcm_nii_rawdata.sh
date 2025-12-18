#!/bin/bash
sourcedata_path=/Users/joshgoh/Teaching/REP/data/sourcedata
rawdata_path=/Users/joshgoh/Teaching/REP/data/rawdata
cd ${sourcedata_path}
for subj_dir in *; do
	mkdir -p ${rawdata_path}/${subj_dir}/nii/
	dcm2niix -o ${rawdata_path}/${subj_dir}/nii/ ${subj_dir}
done