#!/bin/tcsh

# Run FS *on a cluster* (NIH's Biowulf) with AFNI

# ======================= A general biowulf script =======================

###  Run this command with something like
#
#   sbatch                                                            \
#      --partition=norm                                               \
#      --cpus-per-task=4                                              \
#      --mem=4g                                                       \
#      --time=12:00:00                                                \
#      --gres=lscratch:10                                             \
#      do_*.tcsh
#
# ===================================================================

source /etc/profile.d/modules.csh
module load afni freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.csh

# labels
set subj          = sub-001

# directories
set dir_inroot    = ../
set dir_log       = ${dir_inroot}/logs
set dir_basic     = ${dir_inroot}/data_00_basic/${subj}
set dir_fs        = ${dir_inroot}/data_02_fs/${subj}
set dir_suma      = ${dir_fs}/SUMA

# dsets
set dset_anat0    = ${dir_basic}/ses-01/anat/${subj}_ses-01_mprage_run-1_T1w.nii.gz

# logs
set log_fsA       = ${dir_log}/log_02_fs-A_${subj}.txt
set log_fsB       = ${dir_log}/log_02_fs-B_${subj}.txt

# ---------------- Biowulf slurm check and initializing ----------------

# Set thread count if we are running SLURM
if ( $?SLURM_CPUS_PER_TASK ) then
  setenv OMP_NUM_THREADS $SLURM_CPUS_PER_TASK
endif

# Set temporary output directory; then requires using something like
# this on the swarm command line: --sbatch '--gres=lscratch:50'.
# These variables used again *after* the main commands, if running
# on Biowulf.
if ( -d /lscratch/$SLURM_JOBID ) then
  set tempdir = /lscratch/$SLURM_JOBID
  set usetemp = 1
else
  set tempdir = ${dir_fs}
  set usetemp = 0
endif

\mkdir -p ${tempdir}

# record any failures; def: no errors
set EXIT_CODE = 0

# ---------------------- Run programs of interest ----------------------

\mkdir -p ${dir_log}

set nomp   = `afni_check_omp`
echo "++ Should be using this many threads: ${nomp}"                  \
     > ${log_fsA}


time recon-all                                                        \
    -all                                                              \
    -3T                                                               \
    -sd      ${tempdir}                                               \
    -subjid  ${subj}                                                  \
    -i       ${dset_anat0}                                            \
    -parallel                                                         \
    |& tee -a ${log_fsA}

if ( $status ) then
    echo "** ERROR running FS recon-all"                              \
        |& tee -a ${log_fsA}
    set EXIT_CODE = 1
    goto JUMP_EXIT
else
    echo "++ GOOD run of FS recon-all"                                \
        |& tee -a ${log_fsA}
endif


@SUMA_Make_Spec_FS                                                    \
    -fs_setup                                                         \
    -NIFTI                                                            \
    -sid    ${subj}                                                   \
    -fspath ${tempdir}/${subj}                                        \
    |& tee  ${log_fsB}

if ( $status ) then
    echo "** ERROR running @SUMA_Make_Spec_FS"                        \
        |& tee -a ${log_fsB}
    set EXIT_CODE = 2
    goto JUMP_EXIT
else
    echo "++ GOOD run of @SUMA_Make_Spec_FS"                          \
        |& tee -a ${log_fsB}
endif

# ===================================================================

JUMP_EXIT:

# ---------------- Biowulf slurm finish and copying ----------------

# Again, Biowulf-running considerations: if processing went fine and
# we were using a temporary directory, copy data back.
if( $usetemp && -d ${tempdir} ) then
    echo "++ Copy from: ${tempdir}" 
    echo "          to: ${dir_fs}"
    \mkdir -p ${dir_fs}
    \cp -pr ${tempdir}/${subj}/* ${dir_fs}/.
endif

# ----------------------------------------------------------------------

if ( $EXIT_CODE ) then
    echo "** Something failed in Step ${EXIT_CODE} for subj: ${subj}"
else
    echo "++ Copy complete for subj: ${subj}" 
endif

# ===================================================================



