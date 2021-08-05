#!/bin/tcsh

# AP: basic, multiecho rest, with blip up/down correction
#  -> the Biowulf version

# This script runs a corresponding do_*.tcsh script, for a given
# subj+ses pair.  It could be adapted to loop over many subj+ses values.

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 22_ap_me_b

# labels
set subj          = sub-001
set ses           = ses-01

# upper directories
set dir_scr       = $PWD
set dir_inroot    = ..
set dir_log       = ${dir_inroot}/logs
set dir_swarm     = ${dir_inroot}/swarms

# running
set scr_swarm     = ${dir_swarm}/swarm_${cmd}.txt

# --------------------------------------------------------------------------

\mkdir -p ${dir_swarm}
\mkdir -p ${dir_log}

# clear away older swarm script 
if ( -e ${scr_swarm} ) then
    \rm ${scr_swarm}
endif

# --------------------------------------------------------------------------

# run command script (verbosely, and don't use '-e'); log terminal text.

cat <<EOF >> ${scr_swarm}
tcsh -xf ${dir_scr}/do_${cmd}.tcsh  ${subj} ${ses} |& tee ${dir_log}/log_${cmd}_${subj}_${ses}.txt
EOF

echo "++ And start swarming: ${scr_swarm}"

swarm                                                              \
    -f ${scr_swarm}                                                \
    --partition=norm,quick                                         \
    --threads-per-process=8                                        \
    --gb-per-process=10                                            \
    --time=03:59:00                                                \
    --gres=lscratch:10                                             \
    --logdir=${dir_log}                                            \
    --job-name=job_${cmd}                                          \
    --merge-output                                                 \
    --usecsh
