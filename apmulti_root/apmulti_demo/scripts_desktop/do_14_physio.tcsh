#!/bin/tcsh

# SSW: run @SSwarper to skullstrip (SS) and estimate a nonlinear warp.

# Process a single subj+ses pair.  Run this script in
# apmulti_demo/scripts/, via the corresponding run_*tcsh script.

# This is a Biowulf script.  Run it via swarm (see partner run*.tcsh).

# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# top level definitions (constant across demo)
# ---------------------------------------------------------------------------

# labels
set subj           = $1
set ses            = $2

set template       = MNI152_2009_template_SSW.nii.gz 

# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw
set dir_physio     = ${dir_inroot}/data_14_physio

set dir_ap_se      = ${dir_inroot}/data_20_ap_se
set dir_ap_me      = ${dir_inroot}/data_21_ap_me
set dir_ap_me_b    = ${dir_inroot}/data_22_ap_me_b
set dir_ap_me_bt   = ${dir_inroot}/data_23_ap_me_bt
set dir_ap_me_bts  = ${dir_inroot}/data_24_ap_me_bts

# subject directories
set sdir_basic     = ${dir_basic}/${subj}/${ses}
set sdir_epi       = ${sdir_basic}/func
set sdir_fs        = ${dir_fs}/${subj}/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj}/${ses}
set sdir_physio    = ${dir_physio}/${subj}/${ses}

set sdir_ap_se     = ${dir_ap_se}/${subj}/${ses}
set sdir_ap_me     = ${dir_ap_me}/${subj}/${ses}
set sdir_ap_me_b   = ${dir_ap_me_b}/${subj}/${ses}
set sdir_ap_me_bt  = ${dir_ap_me_bt}/${subj}/${ses}
set sdir_ap_me_bts = ${dir_ap_me_bts}/${subj}/${ses}

# set work directory
set sdir_work = ${sdir_physio}

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set task_label  = task-rest_run-1_physio
set physio_card = ${subj}_${ses}_${task_label}-ECG.txt
set physio_resp = ${subj}_${ses}_${task_label}-Resp.txt


# control variables

# check available N_threads and report what is being used
set nthr_avail = `afni_system_check.py -check_all | \
                      grep "number of CPUs:" | awk '{print $4}'`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_avail} of available ${nthr_using} threads"

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

# make output directory, copy inputs there, and go to it
mkdir -p ${sdir_work}
cp -p ${sdir_epi}/${physio_card} ${sdir_work}
cp -p ${sdir_epi}/${physio_resp} ${sdir_work}
cd ${sdir_work}

# create command script
set run_script = run_retrots.txt

cat << EOF >! ${run_script}

# 33 slices of 220 time points * 50 vals/s * 2.2 s/time_point
# --> 24200 vals (220 TP * 110 vals/TP)

wc ${physio_resp} ${physio_card}

RetroTS.py -prefix ${subj}_${ses}_${task_label} \
           -r ${physio_resp}                    \
           -c ${physio_card}                    \
           -p 50 -n 33 -v 2.2

EOF

# and run it
tcsh -xf ${run_script} |& tee out.${run_script}

set ecode = ${status}
if ( ${ecode} ) then
    echo "++ FAILED EXECUTION"
else
    echo "++ FINISHED EXECUTION"
endif

# ---------------------------------------------------------------------------

exit $ecode

