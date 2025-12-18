#!/bin/bash
#
# Setup (with option to run) SPM25 coregistration module using shell 
# script invoking matlab.
#
# Usage: spm_normalise-sst-mni TEMPLATE FLOW_FIELD_LIST IMAGE_FILE_LIST SMOOTH_KERNEL mbfn rf
#
# TEMPLATE - Fullpath to SST.
# FLOW_FIELD_LIST - Filename of text file with subject flow field (u_*.nii) per line.
# IMAGE_FILE_LIST - Filename of text file with space separated subject image files for normalisation per line.
# SMOOTH_KERNEL - 3D Gaussian FWHM smoothing kernel (e.g. 8,8,8)
# mbfn - Matlab batch output file name.
# rf - flag to run matlabbatch, 0: no, 1: yes
#
# 20251031 Created by Josh Goh.

# Assign parameters
TEMPLATE=${1}
FLOW_FIELD_LIST=${2}
IMAGE_FILE_LIST=${3}
SMOOTH_KERNEL=${4}
mbfn=${5}
rf=${6}


# Call matlab with input script
unset DISPLAY
matlab -nodesktop -nosplash > matlab.out << EOF
	settings;
	FLOW = readlines('${FLOW_FIELD_LIST}','EmptyLineRule','skip');
	IMAGE_LINES = readlines('${IMAGE_FILE_LIST}','EmptyLineRule','skip');
	N_FLOW = size(FLOW,1);
	for SUBJ=1:N_FLOW,
		matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(SUBJ).flowfield = {deblank(FLOW{SUBJ})};
		matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(SUBJ).images = cellstr(split(IMAGE_LINES(SUBJ)));
	end;
	matlabbatch{1}.spm.tools.dartel.mni_norm.template = {'${TEMPLATE}'};
	matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
	matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN; NaN NaN NaN];
	matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
	matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [${SMOOTH_KERNEL}];

	save('${mbfn}','matlabbatch');
  	if ${rf},
    		spm_jobman('run',matlabbatch);
  	end
exit;

EOF
