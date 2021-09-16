#!/bin/tcsh

# AP: basic, single echo rest, based on example 11

# This script runs a corresponding do_*.tcsh script, for a given
# subj+ses pair.  It could be adapted to loop over many subj+ses values.

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 20_ap_se

# labels
set subj          = sub-004
set ses           = ses-01

# upper directories
set dir_inroot    = ..
set dir_log       = ${dir_inroot}/logs

# --------------------------------------------------------------------------

# run command script (verbosely and stop at any failure); log terminal text.

tcsh -xef do_${cmd}.tcsh  ${subj} ${ses}                           \
    |& tee ${dir_log}/log_${cmd}_${subj}_${ses}.txt

