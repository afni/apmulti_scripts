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

module load afni

# labels
set subj          = sub-001

# directories
set dir_inroot    = ../
set dir_log       = ${dir_inroot}/logs
set dir_basic     = ${dir_inroot}/data_00_basic/${subj}
set dir_fs        = ${dir_inroot}/data_02_fs/${subj}
set dir_suma      = ${dir_fs}/SUMA
set dir_ssw       = ${dir_inroot}/data_03_ssw/${subj}

# dsets
set dset_anat0    = ${dir_basic}/ses-01/anat/${subj}_ses-01-mprage_run-1_T1w.nii.gz

# logs
set log_ssw       = ${dir_log}/log_03_ssw_${subj}.txt

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
     > ${log_ssw}


time @SSwarper                                                        \
    -input   ${dset_anat0}                                            \
    -base    MNI152_2009_template_SSW.nii.gz                          \
    -odir    ${tempdir}                                               \
    -subid   ${subj}                                                  \
    |& tee -a ${log_ssw}

if ( $status ) then
    echo "** ERROR running SSW"                                       \
        |& tee -a ${log_ssw}
    set EXIT_CODE = 1
    goto JUMP_EXIT
else
    echo "++ GOOD run of SSW"                                         \
        |& tee -a ${log_ssw}
endif

# ===================================================================

JUMP_EXIT:

# ---------------- Biowulf slurm finish and copying ----------------

# Again, Biowulf-running considerations: if processing went fine and
# we were using a temporary directory, copy data back.
if( $usetemp && -d ${tempdir} ) then
    echo "++ Copy from: ${tempdir}" 
    echo "          to: ${dir_ssw}"
    \mkdir -p ${dir_ssw}
    \cp -pr ${tempdir}/* ${dir_ssw}/.
endif

# ----------------------------------------------------------------------

if ( $EXIT_CODE ) then
    echo "** Something failed in Step ${EXIT_CODE} for subj: ${subj}"
else
    echo "++ Copy complete for subj: ${subj}" 
endif

# ===================================================================



