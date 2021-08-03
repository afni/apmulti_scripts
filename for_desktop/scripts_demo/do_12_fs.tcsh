#!/bin/tcsh

# FS: run FreeSurfer's recon-all and AFNI's @SUMA_Make_Spec_FS.

# Process a single subj+ses pair.  Run this script via the
# corresponding run_*tcsh script.

# --------------------------------------------------------------------------
# data and control variables
# ---------------------------------------------------------------------------

# labels
set subj          = $1
set ses           = $2

set template      = MNI152_2009_template_SSW.nii.gz 

# upper directories
set dir_inroot    = ../
set dir_log       = ${dir_inroot}/logs
set dir_basic     = ${dir_inroot}/data_00_basic
set dir_fs        = ${dir_inroot}/data_12_fs
set dir_ssw       = ${dir_inroot}/data_13_ssw

# subject directories
set sdir_basic    = ${dir_basic}/${subj}/${ses}
set sdir_fs       = ${dir_fs}/${subj}/${ses}
set sdir_suma     = ${sdir_fs}/SUMA
set sdir_ssw      = ${dir_ssw}/${subj}/${ses}

# --------------------------------------------------------------------------

# dataset inputs
set dset_anat_00  = ${sdir_basic}/anat/${subj}_${ses}_mprage_run-1_T1w.nii.gz

# control variables

# thread usage
# + check available N_threads and report what is being used
# + consider using up to 4 threads, because of "-parallel" in recon-all
# + N_threads may be set elsewhere; to set here, uncomment the following line:
### setenv OMP_NUM_THREADS 4

set nthr_avail = `afni_system_check.py -check_all | \
                      grep "number of CPUs:" | awk '{print $4}'`
set nthr_using = `afni_check_omp`

echo "++ INFO: Using ${nthr_avail} of available ${nthr_using} threads"

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

\mkdir -p ${sdir_fs}

time recon-all                                                        \
    -all                                                              \
    -3T                                                               \
    -parallel                                                         \
    -sd        "${sdir_fs}"                                           \
    -subjid    "${subj}"                                              \
    -i         "${dset_anat_00}"

# compress path (because of recon-all output dir naming): 
#   move output from DIR/${subj}/${ses}/${subj}/* to DIR/${subj}/${ses}/*
\mv ${sdir_fs}/${subj}/* ${sdir_fs}/.
\rmdir ${sdir_fs}/${subj}

@SUMA_Make_Spec_FS                                                    \
    -fs_setup                                                         \
    -NIFTI                                                            \
    -sid       "${subj}"                                              \
    -fspath    "${sdir_fs}"

echo "++ FINISHED FS"

exit 0

