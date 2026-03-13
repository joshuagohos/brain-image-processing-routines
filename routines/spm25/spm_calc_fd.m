% Calculate FD (Framewise Displacement) from specified motion parameter
% files. The function will extract 
% Usage: FD = caculate_FD(rp_file)
%
% Input:
%   rp_file - the txt file which generated afted SPM realignment.
%
% Output:
%   FD - the FD for your data.
%
% Dependendies: 
%   NONE
%
% Update log:
% Yu-Shiang Su 15 Jun 2016: Created

function FD = calculate_FD(rp_file)
%rp_file = spm_select();
rp_file_fid = fopen(rp_file);
HeadMot = cell2mat(textscan(rp_file_fid, '%f%f%f%f%f%f'));
FD = zeros(180,1);
for k = 1:(size(HeadMot,1)-1)
    FD(k+1) = abs(HeadMot(k+1,1) - HeadMot(k,1)) + ...
        abs(HeadMot(k+1,2) - HeadMot(k,2)) + ...
        abs(HeadMot(k+1,3) - HeadMot(k,3)) + ...
        abs(HeadMot(k+1,4) - HeadMot(k,4))*50 + ...
        abs(HeadMot(k+1,5) - HeadMot(k,5))*50 + ...
        abs(HeadMot(k+1,6) - HeadMot(k,6))*50;
end
fclose(rp_file_fid);