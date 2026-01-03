#!/bin/bash
#
# Setup (with option to run) SPM25 PhysIO module to extract regressors per EPI using 
# shell script invoking matlab. Current configurable parameters are set based on 
# standard fMRI usage. These include motion parameters and WM and CSF mask signals. 
# Submodule parameters for log_files, cardiac) are currently left at default in this 
# version (i.e., ignored).
#
# Usage: spm_denoise_physio output_dir inputdat tr refslice slice_to_slice wm_mask csf_mask mask_threshold regdat mbfn
#
# output_dir - Directory for outputs.
# inputdat - Singular image, or text filename
#              with fullpaths per row per image.
# tr - Repetition time in s.
# refslice - Target slice to which timing is adjuste to.
# slice_to_slice - Duration between acquisition of two different slices (tr/nslices)
# wm_mask - White matter segmentation mask nii volume.
# csf_mask - CSF segmentation mask nii volume.
# mask_threshold - Threshold ratio for mask tissue probability inclusion.
# regdat - Text filename with fullpaths to rp*_.txt per row per EPI.
# mbfn - Matlab batch base output file name.
#
# 20251231 Created by Josh Goh.

# Assign parameters
output_dir=${1}
inputdat=${2}
tr=${3}
refslice=${4}
slice_to_slice=${5}
wm_mask=${6}
csf_mask=${7}
mask_threshold=${8}
regdat=${9}
mbfn=${10}

# Call matlab with input script
unset DISPLAY
matlab -nosplash > matlab.out << EOF
    settings;
    matlabbatch{1}.spm.tools.physio.save_dir = {'${output_dir}'};
    matlabbatch{1}.spm.tools.physio.write_bids.bids_step = 0;
    matlabbatch{1}.spm.tools.physio.write_bids.bids_dir = {''};
    matlabbatch{1}.spm.tools.physio.write_bids.bids_prefix = 'sub-control01_task-YOURTASK_run-1';
    REG = readlines('${regdat}','EmptyLineRule','skip');
    [p n e] = fileparts('${inputdat}');
    if strcmp(e,'.nii'),
        nrun = 1;
        S = {'${inputdat}'};
    else
        S = textread('${inputdat}','%s');
        nrun = size(S,1);
    end
    mask(1).vol = '${wm_mask}';
    mask(2).vol = '${csf_mask}';
    tr=${tr};
    for r = 1:nrun,
        ni = niftiinfo(S{r});
        nvols = ni.ImageSize(4);
        nslices=ni.ImageSize(3);
        matlabbatch{1}.spm.tools.physio.log_files.vendor = 'Philips';
        matlabbatch{1}.spm.tools.physio.log_files.cardiac = {''};
        matlabbatch{1}.spm.tools.physio.log_files.respiration = {''};
        matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {''};
        matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
        matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
        matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'last';
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = nslices;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = tr;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = nvols;
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = ${refslice};
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = ${slice_to_slice};
        matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
        matlabbatch{1}.spm.tools.physio.scan_timing.sync.nominal = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.modality = 'ECG';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.filter.no = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.max_heart_rate_bpm = 90;
        matlabbatch{1}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
        matlabbatch{1}.spm.tools.physio.preproc.respiratory.filter.passband = [0.01 2];
        matlabbatch{1}.spm.tools.physio.preproc.respiratory.despike = false;
        matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = ['multiple_regressors_epi' num2str(r) '.txt'];
        matlabbatch{1}.spm.tools.physio.model.output_physio = ['physio_epi' num2str(r) '.mat'];
        matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
        matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
        matlabbatch{1}.spm.tools.physio.model.retroicor.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.fmri_files = {deblank(S{r})};
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.roi_files = cellstr(strvcat(mask.vol));
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.force_coregister = 'Yes';
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.thresholds = ${mask_threshold};
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_voxel_crop = 0;
        matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_components = 5;
        matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {deblank(REG{r})};
        matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 24;
        matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_method = 'FD';
        matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_threshold = 0.5;
        matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
        matlabbatch{1}.spm.tools.physio.verbose.level = 1;
        matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = '';
        matlabbatch{1}.spm.tools.physio.verbose.use_tabs = 0;

        save(['${mbfn}_epi' num2str(r)],'matlabbatch');
        spm_jobman('run',matlabbatch);
    end
exit;
EOF