#!/bin/tcsh

# FS: run FreeSurfer's recon-all and AFNI's @SUMA_Make_Spec_FS.
#  -> Biowulf version

# This script runs a corresponding do_*.tcsh script, for a given
# subj+ses pair.  It could be adapted to loop over many subj+ses values.

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 12_fs

# labels
set subj          = sub-001
set ses           = ses-01

# upper directories
set dir_scr       = $PWD
set dir_inroot    = ../
set dir_log       = ${dir_inroot}/logs

# running
set scr_swarm     = ${dir_log}/swarm_${cmd}.txt

# --------------------------------------------------------------------------

# run command script (verbosely); log terminal text.

cat <<EOF >> ${scr_swarm}
tcsh -ef ${dir_scr}/do_${cmd}.tcsh  ${subj} ${ses} |& tee ${dir_log}/log_${cmd}_${subj}_${ses}.txt
EOF

echo "++ And start swarming"

swarm                                                              \
    -f ${scr_swarm}                                                \
    --partition=norm                                               \
    --cpus-per-task=4                                              \
    --mem=10g                                                      \
    --time=12:00:00                                                \
    --gres=lscratch:10                                             \
    --logdir=${dir_log}                                            \
    --merge-output                                                 \
    --usecsh
