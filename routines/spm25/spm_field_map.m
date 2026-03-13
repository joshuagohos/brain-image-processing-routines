% Apply bias field image (B) onto image data (P).
%
% Direct Usage: apply_bias_field_image(B,P)
%
% B - String of bias field image nifti filepath + filename.
% P - String array of image data to apply B onto (filepath(s) +
%     filename(s)).
%
% - Requires SPM.
% - Made to run under SPM batch editor 'Call Matlab function'.
%   To run there, first ensure function script is in path.
%   Enter F = @apply_bias_field_image in cmd line.
%   Then call F in Call Matlab function: Function to be called.
%
% Created by JG 20191016
% Help updated by JG 20250513.
%addpath(pwd)

function VBP_fname = apply_bias_field_image(B,P)

if nargin < 2
    error('Specify input files');
end

if ~iscell(B)
    B = cellstr(B);
end

if ~iscell(P)
    P = cellstr(P);
end

VB = spm_vol(B);
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
