#!/bin/tcsh

# AP: basic, multiecho rest, with blip up/down correction and
# tedana.py, processing on a *surface*

# This script runs a corresponding do_*.tcsh script, for a given
# subj+ses pair.  It could be adapted to loop over many subj+ses values.

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 24_ap_me_bts

# labels
set subj          = sub-005
set ses           = ses-01

# upper directories
set dir_scr       = $PWD
set dir_inroot    = ..
set dir_log       = ${dir_inroot}/logs

# running
set cdir_log      = ${dir_log}/logs_${cmd}
set scr_cmd       = ${dir_scr}/do_${cmd}.tcsh

# --------------------------------------------------------------------------

# make directory for storing text files to log the processing
\mkdir -p ${cdir_log}

# --------------------------------------------------------------------------

set log = ${cdir_log}/log_${cmd}_${subj}_${ses}.txt

# run command script (verbosely and stop at any failure); log terminal text.

tcsh -xf ${scr_cmd} ${subj} ${ses} |& tee ${log}


