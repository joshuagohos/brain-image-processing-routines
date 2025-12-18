#!/bin/bash
#
# Setup (with option to run) SPM25 slice-timing EPI module using shell 
# script invoking matlab.
#
# Usage: spm_slice-timing inputdat refslice so_spec ta mbfn rf
#
# inputdat - Singular EPI .nii fullpath or text filename with fullpaths
#            per row per EPI.
# refslice - Target slice to adjust timing to.
# so_spec - Vector or evaluation string of slice order.
# ta - Double or evaluation string of time of acquisition.
# mbfn - Matlab batch output file name.
# rf - flag to run matlabbatch, 0: no, 1: yes
#
# 20220518 Created by Josh Goh.

# Assign parameters
inputdat=${1}
refslice=${2}
so_spec=${3}
ta=${4}
mbfn=${5}
rf=${6}

# Call matlab with input script
unset DISPLAY
matlab -nodesktop -nosplash > matlab.out << EOF
  settings;
  [p n e] = fileparts('${inputdat}');
  if strcmp(e,'.nii'),
	 nrun = 1;
	 S = {'${inputdat}'};
  else
	 S = textread('${inputdat}','%s');
	 nrun = size(S,1);
  end
  for r = 1:nrun,
	 ni = niftiinfo(S{r});
	 nvols = ni.ImageSize(4);
	 for t = 1:nvols,
	   temp(t).epivol = [deblank(S{r}) ',' num2str(t)];
	 end;
   matlabbatch{1,1}.spm.temporal.st.scans{1,r} = cellstr(strvcat(temp.epivol));
  end
  nslices = ni.ImageSize(3);
  tr = ni.PixelDimensions(4);
  matlabbatch{1,1}.spm.temporal.st.nslices = nslices;
  matlabbatch{1,1}.spm.temporal.st.tr = tr;
  matlabbatch{1,1}.spm.temporal.st.ta = ${ta};
  matlabbatch{1,1}.spm.temporal.st.so = ${so_spec};
  matlabbatch{1,1}.spm.temporal.st.refslice = ${refslice};
  matlabbatch{1,1}.spm.temporal.st.prefix = 'a';
  save('${mbfn}','matlabbatch');
  if ${rf},
    spm_jobman('run',matlabbatch);
  end
exit;
EOF
