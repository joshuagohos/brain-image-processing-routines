% Load existing known matlabbatch, replace strings, save new matlabbatch.
% Requires recursiveStrRep.m in path.

% Set environmental paths
PROJECT_DIR= '/home/joshgoh/projects/REP';

% Set targetStr nii file category files
target(1).file = '/Users/joshgoh/Teaching/REP/data/derivatives/y01/nii/y01_T1_MPRAGE_sag_1.25_hippo_20080130101823_13.nii';
target(2).file = '/Users/joshgoh/Teaching/REP/data/derivatives/y01/nii/y01_t2_tse_tra_32slice,pre-epi_20080130101823_22.nii';
target(3).file = '/Users/joshgoh/Teaching/REP/data/derivatives/y01/nii/y01_REP1_150BR_32_sl_20080130101823_23.nii';
target(4).file = '/Users/joshgoh/Teaching/REP/data/derivatives/y01/nii/y01_REP2_150BR_32_sl_20080130101823_25.nii';
target(5).file = '/Applications/spm/tpm/TPM.nii';

% Read newStr nii file category lists (ensure newStr categories correspond to the order in targetStr)
LIST(1).list = readlines([PROJECT_DIR '/code/T1_list']);
LIST(2).list = readlines([PROJECT_DIR '/code/T2_list']);
LIST(3).list = readlines([PROJECT_DIR '/code/REP1_list']);
LIST(4).list = readlines([PROJECT_DIR '/code/REP2_list']);
LIST(5).list = '/opt/spm/tpm/TPM.nii';

% Read subject id list
subj_id = readlines([PROJECT_DIR '/code/subj_id_list']);

% Loop over subjects
for S = 1:37
	
	% Load base matlabbatch
	load([PROJECT_DIR '/code/y01_preproc_realign-segment_copy.mat']);
	
	% Loop over nii file categories
	for L = 1:4
		% Define target and new strings
		targetStr = target(L).file;
		newStr = LIST(L).list{S};

		% Run the recursive function on entire matlabbatch cell
		matlabbatch = recursiveStrRep(matlabbatch, targetStr, newStr);
	end
	
	% Singular nii file categories
	% Define target and new strings
	targetStr = target(5).file;
	newStr = LIST(5).list;

	% Run the recursive function on entire matlabbatch cell
	matlabbatch = recursiveStrRep(matlabbatch, targetStr, newStr);
	
	% Save new matlabbatch
	save([PROJECT_DIR '/code/' subj_id{S} '_preproc_realign-segment.mat'],'matlabbatch');
end

disp('Batch update(s) complete.');
