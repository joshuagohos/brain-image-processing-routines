#!/bin/bash
#
# Use SPM25 and apply bias field image (B) onto image data (P) 
# using shell script invoking matlab.
#
# Usage: spm_apply_bias_field_image B P
#
# B - String of bias field image nifti filepath + filename.
# P - Singular image (.nii) fullpath or text filename with fullpaths
#            per row per image.
#
# Created by JG 20191016
# Help updated by JG 20250513. 
# Updated 20260320 by JG. Modified for pipeline.

# Assign parameters
B=${1}
P=${2}
mbfn=${3}
rf=${4}

# Call matlab with input script
unset DISPLAY
matlab -nosplash > matlab.out << EOF
    settings
    [p n e] = fileparts('${P}');
    if strcmp(e,'.nii'),
        nrun = 1;
	    S = {'${P}'};
    else
	    S = textread('${P}','%s');
	    nrun = size(S,1);
    end
    for r = 1:nrun,
        ni = niftiinfo(S{r});
        nvols = ni.ImageSize(4);
        for t = 1:nvols,
        temp(t).epivol = [deblank(S{r}) ',' num2str(t)];
        end;
        matlabbatch{1,1}.spm.spatial.realign.estwrite.data{1,r} = cellstr(strvcat(temp.epivol));
    end;

    VB = spm_vol('${B}');
    if length(VB) > 1
        error('Biased image should have only one.')
    end
    YB = spm_read_vols(VB{1});

    VBP_fname = cell(size(P,1), 1);
    for i = 1:size(P,1)
        VP = spm_vol(P{i,1});
        YP = spm_read_vols(VP);        
        VBP = VP;
        
        [p, n, e] = fileparts(VP.fname);
        
        YBP = YB.*YP;
        VBP.fname = [p '/b' n e];
        VBP_fname{i} = [p '/b' n e ',' num2str(i)];
        spm_write_vol(VBP, YBP);
        
    %     if length(VP)>1 % Handle 4D volumes        
    %         for j = 1:length(cellstr(VP))
    %             [p, n, e] = fileparts(VP(j).fname);
    %             YBP = YB.*YP(:,:,:,j);
    %             VBP(j).fname = [p '/b' n e];
    %             VBP(j).n = [j 1];
    % 
    %             spm_write_vol(VBP(j), YBP);           
    %         end       
    %     else
    %         YBP = YB.*YP;
    %         VP.fname = [p '/b' n e];
    %         spm_write_vol(VP,YBP)
    %     end    
    end
exit;
EOF