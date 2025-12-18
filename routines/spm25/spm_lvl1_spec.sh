#!/bin/bash
#
# Setup (with option to run) SPM25 1st-level specification using 
# shell script invoking matlab.
#
# Usage: spm_lvl1_spec inputdat conddat regdat results_dir units tr microtime_res microtime_ons mask mask_thresh mbfn rf
#
# inputdat - Singular EPI .nii fullpath or text filename with fullpaths
#            per row per EPI.
# conddat - Text filename with fullpaths to *_soa.mat per row per EPI.
# regdat - Text filename with fullpaths to rp*_.txt per row per EPI.
# results_dir - Directory for specification output (SPM.mat)
# units - 'secs' or 'scans'.
# tr - Repetition time in s.
# microtime_res - Number of slices or number of time bins per scan.
# microtime_ons - Reference slice or reference time bin.
# mask - Text fullpath to explicit mask *.nii or ''.
# mask_thresh - Probability
# mbfn - Matlab batch output file name.
# rf - flag to run matlabbatch, 0: no, 1: yes
#
# 20251117 Created by Josh Goh.

# Assign parameters
inputdat=${1}
conddat=${2}
regdat=${3}
results_dir=${4}
units=${5}
tr=${6}
microtime_res=${7}
microtime_ons=${8}
mask=${9}
mask_thresh=${10}
mbfn=${11}
rf=${12}

# Call matlab with input script
unset DISPLAY
matlab -nosplash -nodesktop > matlab.out << EOF
  settings;
  COND = readlines('${conddat}','EmptyLineRule','skip');
  REG = readlines('${regdat}','EmptyLineRule','skip');
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
	 matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = cellstr(strvcat(temp.epivol));
	 matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond = struct('name',{},'onset',{},'duration',{},'tmod',{},'pmod',{},'orth',{});
	 matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi = {deblank(COND{r})};
	 matlabbatch{1}.spm.stats.fmri_spec.sess(r).regress = struct('names',{},'val',{});
	 matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = {deblank(REG{r})};
	 matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = 128;
  end;
  matlabbatch{1}.spm.stats.fmri_spec.dir = {'${results_dir}'};
  matlabbatch{1}.spm.stats.fmri_spec.timing.units = '${units}';
  matlabbatch{1}.spm.stats.fmri_spec.timing.RT = ${tr};
  matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = ${microtime_res};
  matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = ${microtime_ons};
  matlabbatch{1}.spm.stats.fmri_spec.fact = struct('names',{},'levels',{});
  matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
  matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
  matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
  matlabbatch{1}.spm.stats.fmri_spec.mthresh = ${mask_thresh};
  matlabbatch{1}.spm.stats.fmri_spec.mask = {'${mask}'};
  matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
  
  save('${mbfn}','matlabbatch');
  if ${rf},
    spm_jobman('run',matlabbatch);
  end
exit;
EOF
