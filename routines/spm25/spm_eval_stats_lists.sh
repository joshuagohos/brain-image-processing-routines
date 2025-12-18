#!/bin/bash
#
# Invokes study stats specific script with input paths to files,
# output file names *_LIST.txt located in results_dir.
# These output files will be used by spm_*.sh to create the spm job file for level 1 or 2
# stats specification or contrasts depending on the script.
#
# Usage: spm_eval_stats_lists MAKE_STATS_LIST_SCRIPT VARARGIN
#
# MAKE_STATS_LIST_SCRIPT - Fullpath to shell script to make txt lists.
# VARGIN - Fullpath to text files with (e.g., *_soa.mat files, 1 file per row (run); SOA_LIST.txt
#                                              CONTYPE_LIST.txt for writing contrast type.
#                                              CONNAME_LIST.txt for writing contrast names.
#                                              CONVEC_LIST.txt for writing contrast vectors.
# 
# 20251119 Created by Josh Goh.

# Specify input and output, and run study specific script

echo "Evaluating study specific stats script."
bash "${1}" "${@:2}"
echo "Study specific stats lists done."
