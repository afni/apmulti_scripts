#!/bin/tcsh

# SSW: run @SSwarper to skullstrip (SS) and estimate a nonlinear warp.

# Process a single subj+ses pair.  Run this script in
# apmulti_demo/scripts/, via the corresponding run_*tcsh script.

# ---------------------------------------------------------------------------
# top level definitions (constant across demo)
# ---------------------------------------------------------------------------

# labels
set subj          = $1
set ses           = $2

set template      = MNI152_2009_template_SSW.nii.gz 

# upper directories
set dir_inroot    = ${PWD:h}                        # one dir above scripts/
set dir_log       = ${dir_inroot}/logs
set dir_basic     = ${dir_inroot}/data_00_basic
set dir_fs        = ${dir_inroot}/data_12_fs
set dir_ssw       = ${dir_inroot}/data_13_ssw

set dir_ap_se     = ${dir_inroot}/data_20_ap_se
set dir_ap_me     = ${dir_inroot}/data_21_ap_me
set dir_ap_me_b   = ${dir_inroot}/data_22_ap_me_b
set dir_ap_me_bt  = ${dir_inroot}/data_23_ap_me_bt
set dir_ap_me_bts = ${dir_inroot}/data_23_ap_me_bts

# subject directories
set sdir_basic    = ${dir_basic}/${subj}/${ses}
set sdir_epi      = ${sdir_basic}/func
set sdir_fs       = ${dir_fs}/${subj}/${ses}
set sdir_suma     = ${sdir_fs}/SUMA
set sdir_ssw      = ${dir_ssw}/${subj}/${ses}

set sdir_ap_se    = ${dir_ap_se}/${subj}/${ses}
set sdir_ap_me    = ${dir_ap_me}/${subj}/${ses}
set sdir_ap_me_b  = ${dir_ap_me_b}/${subj}/${ses}
set sdir_ap_me_bt = ${dir_ap_me_bt}/${subj}/${ses}
set sdir_ap_me_bts = ${dir_ap_me_bts}/${subj}/${ses}

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

# dataset inputs
set dset_anat_00  = ${sdir_basic}/anat/${subj}_${ses}_mprage_run-1_T1w.nii.gz

# control variables

# check available N_threads and report what is being used
# + consider using up to 16 threads (alignment programs are parallelized)
# + N_threads may be set elsewhere; to set here, uncomment the following line:
### setenv OMP_NUM_THREADS 16

set nthr_avail = `afni_system_check.py -check_all | \
                      grep "number of CPUs:" | awk '{print $4}'`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_avail} of available ${nthr_using} threads"

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

time @SSwarper                                                        \
    -base    "${template}"                                            \
    -subid   "${subj}"                                                \
    -input   "${dset_anat_00}"                                        \
    -odir    "${sdir_ssw}"

echo "++ FINISHED SSW"

exit 0
