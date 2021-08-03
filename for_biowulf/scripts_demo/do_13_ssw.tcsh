#!/bin/tcsh

# SSW: run @SSwarper to skullstrip (SS) and estimate a nonlinear warp.
#  -> the Biowulf version.

# Note: (biowulf) when starting sinteractive, sbatch or swarm, allocate
#       /lscratch space of size "SIZE" GB with: '--gres=lscratch:SIZE'

# Process a single subj+ses pair.  Run this script via the
# corresponding run_*tcsh script.

# ----------------------------- biowulf-cmd ---------------------------------
# load modules
source /etc/profile.d/modules.csh
module load afni 

# set N_threads for OpenMP
# + consider using up to 16 threads (alignment programs are parallelized)
setenv OMP_NUM_THREADS = $SLURM_CPUS_PER_TASK

# initial exit code; we don't exit at fail, to copy partial results back
set ecode = 0
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
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
    \cp -pr   ${sdir_ssw}/* ${dir_BW}/.
endif
# ---------------------------------------------------------------------------

exit $ecode

