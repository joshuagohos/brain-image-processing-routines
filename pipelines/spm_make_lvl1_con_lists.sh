#!/bin/bash
#
# STUDY SPECIFIC SCRIPT called by spm_eval_soa.sh to setup CONTYPE, CONNAME, CONVEC text lists  
# using shell script invoking matlab. Text lists are used as input to spm_lvl1_con.sh.
#
# Usage: spm_make_lvl1_con_lists SOA_LIST CONTYPE_LIST CONNAME_LIST CONVEC_LIST
#
# SOA_LIST - Fullpath to text file with *_soa.mat files, 1 file per row (run); SOA_LIST.txt
# CONTYPE_LIST - Fullpath to CONTYPE_LIST.txt for writing contrast type.
# CONNAME_LIST - Fullpath to CONNAME_LIST.txt for writing contrast names.
# CONVEC_LIST - Fullpath to CONVEC_LIST.txt for writing contrast vectors.
# 
# 20251120 Created by Josh Goh.

# Assign parameters
SOA_LIST=${1}
CONTYPE_LIST=${2}
CONNAME_LIST=${3}
CONVEC_LIST=${4}

# Call matlab with input script
unset DISPLAY
matlab -nosplash -nodesktop > matlab.out << EOF
	settings;
	CONTYPE = {'T','T','T'};
	CONNAME = {'P31','P32','P33'};
	for C = 1:length(CONTYPE),
		writelines(CONTYPE{C}, '${CONTYPE_LIST}', 'WriteMode', 'append');
		writelines(CONNAME{C}, '${CONNAME_LIST}', 'WriteMode', 'append');
		SOA_LIST=readlines('${SOA_LIST}','EmptyLineRule','skip');
		CONVEC = zeros(1,15);
		load(deblank(SOA_LIST{1}));
		if length(names)==4,
			CONVEC([C+1,C+11])=1;
		else
			CONVEC([C+1,C+12])=1;
		end
		writelines(num2str(CONVEC), '${CONVEC_LIST}', 'WriteMode', 'append');
	end
exit;
EOF
