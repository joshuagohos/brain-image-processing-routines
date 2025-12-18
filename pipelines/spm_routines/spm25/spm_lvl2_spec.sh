#!/bin/bash
#
# Setup (with option to run) SPM25 2nd-level specification (full factorial) using 
# shell script invoking matlab.
#
# Usage: spm_lvl2_spec results_dir FACTOR_LIST FACTOR_LEVELS_LIST FACTOR_DEP_LIST FACTOR_VAR_LIST CELL_LEVELS_LIST CELL_CON_FILES_LIST mbfn rf
#
# results_dir - Directory for specification output (SPM.mat)
# FACTOR_LIST - Fullpath to text file listing factor names, 1 factor per row.
# FACTOR_LEVELS_LIST - Fullpath to text file listing factor number of levels, 1 number per row.
# FACTOR_DEP_LIST - Fullpath to text file listing factor dependency (1: Dep, 0: Indep), 1 number per row.
# FACTOR_VAR_LIST - Fullpath to text file listing factor variance assumption (1: Uneq, 0: Eq), 1 number per row.
# CELL_LEVELS_LIST - Fullpath to text file listing cell level vectors, 1 double vector per row.
# CELL_CON_FILES_LIST - Fullpath to text file listing text files that list cell contrast *.nii, 1 filename fullpath per row (per cell).
# mbfn - Matlab batch output file name.
# rf - flag to run matlabbatch, 0: no, 1: yes
#
# 20251123 Created by Josh Goh.

# Assign parameters
results_dir=${1}
FACTOR_LIST=${2}
FACTOR_LEVELS_LIST=${3}
FACTOR_DEP_LIST=${4}
FACTOR_VAR_LIST=${5}
CELL_LEVELS_LIST=${6}
CELL_CON_FILES_LIST=${7}
mbfn=${8}
rf=${9}

# Call matlab with input script
unset DISPLAY
matlab -nosplash -nodesktop > matlab.out << EOF
  settings;
  FACTOR = readlines('${FACTOR_LIST}','EmptyLineRule','skip');
  FACTOR_LEVELS = readlines('${FACTOR_LEVELS_LIST}','EmptyLineRule','skip');
  FACTOR_DEP = readlines('${FACTOR_DEP_LIST}','EmptyLineRule','skip');
  FACTOR_VAR = readlines('${FACTOR_VAR_LIST}','EmptyLineRule','skip');
  CELL_LEVELS = readlines('${CELL_LEVELS_LIST}','EmptyLineRule','skip');
  CELL_CON_FILES = readlines('${CELL_CON_FILES_LIST}','EmptyLineRule','skip');
  
  matlabbatch{1}.spm.stats.factorial_design.dir = {'${results_dir}'};
  for F = 1:length(FACTOR),
  	matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(F).name = FACTOR{F};
	matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(F).levels = str2num(FACTOR_LEVELS{F});
	matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(F).dept = str2num(FACTOR_DEP{F}); % 1: Dep, 0: Indep
	matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(F).variance = str2num(FACTOR_VAR{F}); % 1: Uneq, 0; Eq
	matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(F).gmsca = 0;
	matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(F).ancova = 0;
  end;
  for iC = 1:length(CELL_LEVELS),
  	matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(iC).levels = str2num(CELL_LEVELS{iC});
  	CELL_CON_LIST = readlines(CELL_CON_FILES{iC},'EmptyLineRule','skip');
  	for iCcon = 1:length(CELL_CON_LIST),
  		temp(iCcon).convol = deblank(CELL_CON_LIST{iCcon});
  	end
  	matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(iC).scans = cellstr(strvcat(temp.convol));
  	clear temp;
  end
  matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1; % 1: Delete, 0: Keep
  matlabbatch{1}.spm.stats.factorial_design.cov = struct("c",{},"cname",{},"iCFC",{},"iCC",{});
  matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct("files",{},"iCFI",{},"iCC",{});
  matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
  matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
  matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
  matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
  matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
  matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
  
  save('${mbfn}','matlabbatch');
  if ${rf},
    spm_jobman('run',matlabbatch);
  end
exit;
EOF
