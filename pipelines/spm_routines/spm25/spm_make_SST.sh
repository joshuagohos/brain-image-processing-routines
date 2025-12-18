#!/bin/bash
#
# Setup (with option to run) SPM25 coregistration module using shell 
# script invoking matlab.
#
# Usage: spm_make_SST inputdat mbfn rf
#
# inputdat - Text filename with fullpaths per row per 
#            IMAGE type for SST. i.e., rc1, rc2, rc3 ..., rc6. 
# mbfn - Matlab batch output file name.
# rf - flag to run matlabbatch, 0: no, 1: yes
#
# 20251031 Created by Josh Goh.

# Assign parameters
inputdat=${1}
mbfn=${2}
rf=${3}


# Call matlab with input script
unset DISPLAY
matlab -nodesktop -nosplash > matlab.out << EOF
	settings;
	S = textread('${inputdat}','%s');
	nI = size(S,1);
	for IMAGE=1:nI,
		T = textread(S{IMAGE},'%s');
		nF = size(T,1);
		for FILE=1:nF,
			temp(FILE).vol = [deblank(T{FILE})];
		end;
		matlabbatch{1}.spm.tools.dartel.warp.images{1,IMAGE} = cellstr(strvcat(temp.vol));
	end;
	matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
	matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1.0000e-06];
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;

	matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1.0000e-06];
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;

	matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5000 1.0000e-06];
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;

	matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5000 0.2500 1.0000e-06];
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
	
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.2500 0.1250 1.0000e-06];
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
	
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.2500 0.1250 1.0000e-06];
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
	matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5000;

	matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.0100;
	matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
	matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;

	save('${mbfn}','matlabbatch');
  	if ${rf},
    	spm_jobman('run',matlabbatch);
  	end
exit;

EOF
