#!/bin/bash
#
# Setup (with option to run) SPM25 stats contrasts using 
# shell script invoking matlab.
#
# Usage: spm_stats_con spmmat contype conname convec delete_cons mbfn rf
#
# spmmat - Fullpath to SPM.mat.
# contype - Fullpath to text file containing contrast types, one per row.
# conname - Fullpath to text file containing contrast names, one per row corresponding to contype.
# convec - Fullpath to text file containing contrast vectors, one per row corresponding to conname.
# delete_cons - 1: delete previous contrasts, 0: do not delete previous contrasts
# mbfn - Matlab batch output file name.
# rf - flag to run matlabbatch, 0: no, 1: yes
#
# 20251119 Created by Josh Goh.

# Assign parameters
SPMMAT=${1}
CONTYPE_LIST=${2}
CONNAME_LIST=${3}
CONVEC_LIST=${4}
DELETE_CONS=${5}
mbfn=${6}
rf=${7}

# Call matlab with input script
unset DISPLAY
matlab -nosplash -nodesktop > matlab.out << EOF
  settings;
  matlabbatch{1}.spm.stats.con.spmmat = {'${SPMMAT}'};
  CONTYPE = readlines('${CONTYPE_LIST}','EmptyLineRule','skip');
  CONNAME = readlines('${CONNAME_LIST}','EmptyLineRule','skip');
  CONVEC = readlines('${CONVEC_LIST}','EmptyLineRule','skip');
  for C=1:length(CONTYPE)
	  if strcmp(CONTYPE(C),'T'),
	  	matlabbatch{1}.spm.stats.con.consess{C}.tcon.name = deblank(CONNAME{C});
		matlabbatch{1}.spm.stats.con.consess{C}.tcon.weights = str2num(CONVEC{C});
		matlabbatch{1}.spm.stats.con.consess{C}.tcon.sessrep = 'none';
	  else
	  	matlabbatch{1}.spm.stats.con.consess{C}.fcon.name = deblank(CONNAME{C});
		matlabbatch{1}.spm.stats.con.consess{C}.fcon.weights = str2num(CONVEC{C});
		matlabbatch{1}.spm.stats.con.consess{C}.fcon.sessrep = 'none';
	  end
  end
  
  matlabbatch{1}.spm.stats.con.delete = ${DELETE_CONS};
  
  save('${mbfn}','matlabbatch');
  if ${rf},
    spm_jobman('run',matlabbatch);
  end
exit;
EOF
