#!/bin/tcsh

# SSW: run @SSwarper to skullstrip (SS) and estimate a nonlinear warp.

# Process a single subj+ses pair.  Run this script in
# apmulti_demo/scripts/, via the corresponding run_*tcsh script.

# This is a Biowulf script.  Run it via swarm (see partner run*.tcsh).

# ----------------------------- biowulf-cmd ---------------------------------
# load modules
source /etc/profile.d/modules.csh
module load afni 

# set N_threads for OpenMP
# + consider using up to 16 threads (alignment programs are parallelized)
setenv OMP_NUM_THREADS $SLURM_CPUS_PER_TASK

# initial exit code; we don't exit at fail, to copy partial results back
set ecode = 0
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

set dir_ap_se      = ${dir_inroot}/data_20_ap_se
set dir_ap_me      = ${dir_inroot}/data_21_ap_me
set dir_ap_me_b    = ${dir_inroot}/data_22_ap_me_b
set dir_ap_me_bt   = ${dir_inroot}/data_23_ap_me_bt
set dir_ap_me_bts  = ${dir_inroot}/data_23_ap_me_bts

# subject directories
set sdir_basic     = ${dir_basic}/${subj}/${ses}
set sdir_epi       = ${sdir_basic}/func
set sdir_fs        = ${dir_fs}/${subj}/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj}/${ses}

set sdir_ap_se     = ${dir_ap_se}/${subj}/${ses}
set sdir_ap_me     = ${dir_ap_me}/${subj}/${ses}
set sdir_ap_me_b   = ${dir_ap_me_b}/${subj}/${ses}
set sdir_ap_me_bt  = ${dir_ap_me_bt}/${subj}/${ses}
set sdir_ap_me_bts = ${dir_ap_me_bts}/${subj}/${ses}

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set dset_anat_00  = ${sdir_basic}/anat/${subj}_${ses}_mprage_run-1_T1w.nii.gz

# control variables

# check available N_threads and report what is being used
set nthr_avail = `afni_system_check.py -check_all | \
                      grep "number of CPUs:" | awk '{print $4}'`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_avail} of available ${nthr_using} threads"

# ----------------------------- biowulf-cmd --------------------------------
# try to use /lscratch for speed 
if ( -d /lscratch/$SLURM_JOBID ) then
    set usetemp  = 1
    set sdir_BW  = ${sdir_ssw}
    set sdir_ssw = /lscratch/$SLURM_JOBID/${subj}_${ses}
else
    set usetemp  = 0
endif
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

time @SSwarper                                                        \
    -base    "${template}"                                            \
    -subid   "${subj}"                                                \
    -input   "${dset_anat_00}"                                        \
    -odir    "${sdir_ssw}"

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

echo "++ FINISHED SSW"

# ---------------------------------------------------------------------------

COPY_AND_EXIT:

# ----------------------------- biowulf-cmd --------------------------------
# copy back from /lscratch to "real" location
if( ${usetemp} && -d ${sdir_ssw} ) then
    echo "++ Used /lscratch"
    echo "++ Copy from: ${sdir_ssw}"
    echo "          to: ${sdir_BW}"
    \mkdir -p ${sdir_BW}
    \cp -pr   ${sdir_ssw}/* ${sdir_BW}/.
endif
# ---------------------------------------------------------------------------

exit $ecode

