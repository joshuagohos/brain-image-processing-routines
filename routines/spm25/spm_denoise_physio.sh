#!/bin/bash
#
# Setup (with option to run) SPM25 smooth module using shell script 
# invoking matlab.
#
# Usage: spm_smooth otherimgfn kernel mbfn rf
#
# otherimgfn - Singular image (to be smoothed), or text filename
#              with fullpaths per row per image.
# kernel - 3d smoothing kernel. E.g. 8,8,8
# mbfn - Matlab batch output file name.
# rf - flag to run matlabbatch, 0: no, 1: yes
#
# 20220519 Created by Josh Goh.

# Assign parameters
otherimgfn=${1}
kernel=${2}
mbfn=${3}
rf=${4}

# Call matlab with input script
unset DISPLAY
matlab -nosplash > matlab.out << EOF
    settings;

    matlabbatch{1}.spm.tools.physio.save_dir = {[PATH_AXC_RES_TW_Nifti 'sub-' num2str(subj) '/denoise']};
    matlabbatch{1}.spm.tools.physio.log_files.vendor = 'Philips';
    matlabbatch{1}.spm.tools.physio.log_files.cardiac = {''};
    matlabbatch{1}.spm.tools.physio.log_files.respiration = {''};
    matlabbatch{1}.spm.tools.physio.log_files.scan_timing = {''};
    matlabbatch{1}.spm.tools.physio.log_files.sampling_interval = [];
    matlabbatch{1}.spm.tools.physio.log_files.relative_start_acquisition = 0;
    matlabbatch{1}.spm.tools.physio.log_files.align_scan = 'last';
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nslices = 64;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.TR = 0.65;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.Nscans = 626;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.onset_slice = 0;
    matlabbatch{1}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
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
    matlabbatch{1}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';
    matlabbatch{1}.spm.tools.physio.model.output_physio = 'physio.mat';
    matlabbatch{1}.spm.tools.physio.model.orthogonalise = 'none';
    matlabbatch{1}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
    matlabbatch{1}.spm.tools.physio.model.retroicor.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.rvt.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.hrv.no = struct([]);
    matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.fmri_files = {[PATH_AXC_RES_TW_Nifti 'sub-' num2str(subj) '/func/REST' ...
                    '/abuRsub-' num2str(subj) '_REST_acq-EPI_bold.nii']}
    matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.roi_files = {
                                                                    [PATH_AXC_RES_TW_Nifti 'sub-' num2str(subj) '/anat/T1/c2sub-' num2str(subj) '_T1W.nii']
                                                                    [PATH_AXC_RES_TW_Nifti 'sub-' num2str(subj) '/anat/T1/c3sub-' num2str(subj) '_T1W.nii']
                                                                    };
    matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.force_coregister = 'Yes';
    matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.thresholds = 0.95;
    matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_voxel_crop = 0;
    matlabbatch{1}.spm.tools.physio.model.noise_rois.yes.n_components = 5;
    matlabbatch{1}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {[PATH_AXC_RES_TW_Nifti 'sub-' num2str(subj) '/func/REST/rp_Rsub-' num2str(subj) '_REST_acq-EPI_bold.txt']};
    matlabbatch{1}.spm.tools.physio.model.movement.yes.order = 12;
    matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_method = 'none';
    matlabbatch{1}.spm.tools.physio.model.movement.yes.censoring_threshold = 0.5;
    matlabbatch{1}.spm.tools.physio.model.other.no = struct([]);
    matlabbatch{1}.spm.tools.physio.verbose.level = 1;
    matlabbatch{1}.spm.tools.physio.verbose.fig_output_file = 'physio_output_figure.ps';
    matlabbatch{1}.spm.tools.physio.verbose.use_tabs = false;

    %% 
    matlabbatch{2}.spm.stats.fmri_spec.dir = {[PATH_AXC_RES_TW_Nifti 'sub-' num2str(subj) '/First_level']};
    matlabbatch{2}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{2}.spm.stats.fmri_spec.timing.RT = 0.65;
    matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t = 64;
    matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
    matlabbatch{2}.spm.stats.fmri_spec.sess.scans = EPI{1,1}(1:626,1);
    matlabbatch{2}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{2}.spm.stats.fmri_spec.sess.multi = {''};
    matlabbatch{2}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
    matlabbatch{2}.spm.stats.fmri_spec.sess.multi_reg(1) = cfg_dep('TAPAS PhysIO Toolbox: physiological noise regressors file (Multiple Regressors)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','physnoisereg'));
    matlabbatch{2}.spm.stats.fmri_spec.sess.hpf = 128;
    matlabbatch{2}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{2}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{2}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{2}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{2}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{2}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{2}.spm.stats.fmri_spec.cvi = 'AR(1)';
    %% 
    matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;

    save('${mbfn}','matlabbatch');
    if ${rf},
        spm_jobman('run',matlabbatch);
    end
exit;
EOF