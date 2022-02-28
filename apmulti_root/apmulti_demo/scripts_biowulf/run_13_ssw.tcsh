#!/bin/tcsh

# SSW: run @SSwarper to skullstrip (SS) and estimate a nonlinear warp.
#  -> the Biowulf version

# This script runs a corresponding do_*.tcsh script, for a given
# subj+ses pair.  It could be adapted to loop over many subj+ses values.

# To execute:  
#     tcsh RUN_SCRIPT_NAME

# --------------------------------------------------------------------------

# specify script to execute
set cmd           = 13_ssw

# labels
set subj          = sub-005
set ses           = ses-01

# upper directories
set dir_scr       = $PWD
set dir_inroot    = ..
set dir_log       = ${dir_inroot}/logs
set dir_swarm     = ${dir_inroot}/swarms

# running
set cdir_log      = ${dir_log}/logs_${cmd}
set scr_swarm     = ${dir_swarm}/swarm_${cmd}.txt
set scr_cmd       = ${dir_scr}/do_${cmd}.tcsh

# --------------------------------------------------------------------------

\mkdir -p ${cdir_log}
\mkdir -p ${dir_swarm}

# clear away older swarm script 
if ( -e ${scr_swarm} ) then
    \rm ${scr_swarm}
endif

# --------------------------------------------------------------------------

set log = ${cdir_log}/log_${cmd}_${subj}.txt   # _${ses}

# run command script (verbosely, and don't use '-e'); log terminal text.
cat <<EOF >> ${scr_swarm}
tcsh -xf ${scr_cmd} ${subj} ${ses} |& tee ${log}
EOF

echo "++ And start swarming: ${scr_swarm}"

swarm                                                              \
    -f ${scr_swarm}                                                \
    --partition=norm,quick                                         \
    --threads-per-process=16                                       \
    --gb-per-process=10                                            \
    --time=03:59:00                                                \
    --gres=lscratch:3                                              \
    --logdir=${cdir_log}                                           \
    --job-name=job_${cmd}                                          \
    --merge-output                                                 \
    --usecsh
