#!/usr/bin/env tcsh

# copy subject EPI from apmulti_dicom/data_12_NIFTI_EPI
#                    to apmulti_demo/data_00_basic (under subject 'func' dir)
# this should be run from apmulti_root (or scripts)

# ===========================================================================
# main vars to possibly modify

set din_root = apmulti_root
set din_epi  = apmulti_dicom/data_12_NIFTI_EPI
set dout_epi = apmulti_demo/data_00_basic

# ----------------------------------------
# subject ID (for output)
set subj  = sub-004
set ses   = ses-01

# available EPI data
# ( acq-asset acq-blip           \
#   task-naming-1 task-naming-2  \
#   task-recog-1 task-recog-2    \
#   task-rest )
set tasklist = ( acq-blip task-rest )

# ===========================================================================
# verify inputs

# ----------------------------------------------------------------------
# allow for starting from scripts dir
if ( $PWD:t == "scripts" ) then
   cd ..
endif
if ( $PWD:t != $din_root ) then
   echo "** should be run from $din_root/scripts"
   exit 1
endif

# ----------------------------------------------------------------------
# be sure input dirs exist
if ( ! -d $din_epi/$subj/$ses || ! -d $dout_epi ) then
   echo "** missing input dir, $din_epi/$subj/$ses or $dout_epi"
   exit 1
endif

# ===========================================================================
# get to work

# subject directory does not yet need to exist
\mkdir -p $dout_epi/$subj/$ses/func
if ( $status ) then
   exit 1
endif

# copy each task set
echo "++ copying tasks: $tasklist"
echo "   from:          $din_epi to $dout_epi"
foreach task ( $tasklist )
   cp -pv $din_epi/$subj/$ses/*_${task}_* $dout_epi/$subj/$ses/func
end

