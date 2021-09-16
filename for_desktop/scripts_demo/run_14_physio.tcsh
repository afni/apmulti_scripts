#!/bin/tcsh

# physio: run RetroTS.py to get slicewise regressors
#  -> the Biowulf version

# This script runs a corresponding do_*.tcsh script, for a given
# subj+ses pair.  It could be adapted to loop over many subj+ses values.

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 14_physio

# labels
set subj          = sub-004
set ses           = ses-01

# upper directories
set dir_scr       = $PWD
set dir_inroot    = ..
set dir_log       = ${dir_inroot}/logs

# --------------------------------------------------------------------------

\mkdir -p ${dir_log}

# --------------------------------------------------------------------------

# run command script (verbosely, and don't use '-e'); log terminal text.

tcsh -xf ${dir_scr}/do_${cmd}.tcsh  ${subj} ${ses} |& tee ${dir_log}/log_${cmd}_${subj}_${ses}.txt

