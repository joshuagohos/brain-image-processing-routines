#!/bin/bash
#
# Setup (with option to run) SPM25 stats model estimation using 
# shell script invoking matlab.
#
# Usage: spm_stats_est spmmat residuals mbfn rf
#
# spmmat - Fullpath to SPM.mat.
# residuals - Flag to write residuals, 0: no, 1: yes
# mbfn - Matlab batch output file name.
# rf - flag to run matlabbatch, 0: no, 1: yes
#
# 20251119 Created by Josh Goh.

# Assign parameters
SPMMAT=${1}
RESIDUALS=${2}
mbfn=${3}
rf=${4}

# Call matlab with input script
unset DISPLAY
matlab -nosplash -nodesktop > matlab.out << EOF
  settings;
  matlabbatch{1}.spm.stats.fmri_est.spmmat = {'${SPMMAT}'};
  matlabbatch{1}.spm.stats.fmri_est.write_residuals = ${RESIDUALS};
  matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
  
  save('${mbfn}','matlabbatch');
  if ${rf},
    spm_jobman('run',matlabbatch);
  end
exit;
EOF
