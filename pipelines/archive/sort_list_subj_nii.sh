#!/bin/bash
# Sort nii files (when subject data has accumualted) into image type categories needed 
# for project nii preprocessing and write nii lists for each category.
# Good for checking overall data file consistency, also for file selection (edit list for 
# files to be sent for subsequent preprocessing).
# - Created by Josh Goh 20251030

# Set environmental paths
PROJECT_DIR=/home/joshgoh/projects/REP
mkdir -p ${PROJECT_DIR}/data/derivatives/tables

# Loop through subject directories
for subj in ${PROJECT_DIR}/data/derivatives/*; do
	
	# Write Rep1
	ls -1 ${subj}/nii/*REP*.nii | sed -n '1p' >> ${PROJECT_DIR}/data/derivatives/tables/REP1_list
	
	# Write Rep2
	ls -1 ${subj}/nii/*REP*.nii | sed -n '3p' >> ${PROJECT_DIR}/data/derivatives/tables/REP2_list
	
	# Write T1
	ls -1 ${subj}/nii/*T1*.nii >> ${PROJECT_DIR}/data/derivatives/tables/T1_list
	
	# Write T2
	ls -1 ${subj}/nii/*t2*.nii >> ${PROJECT_DIR}/data/derivatives/tables/T2_list
	
done
echo "Done!"
