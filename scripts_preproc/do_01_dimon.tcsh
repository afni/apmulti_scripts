#!/usr/bin/env tcsh

# Run Dimon to create datasets, and populate apmulti_demo tree with result.

set rootd       = apmulti_dicom
set subj        = sub-001
set ses         = ses-01

set din_scripts = scripts
set subj_dicom  = data_00_basic/$subj/$ses
set dout_epi    = data_01_dimon/$subj/$ses/func

# ----------------------------------------------------------------------
# require a reasonable starting location
if ( $PWD:t != $rootd || ! -d $din_scripts || ! -d $subj_dicom ) then
   echo "** must be run from inside the $rootd directory"
   echo "   (and must contain $din_scripts and $subj_dicom)"
   exit 1
endif

# note the full path to the input data
cd $subj_dicom
set subj_dicom_abs = `pwd`
cd -

# note the full path to the scripts directory
cd $din_scripts
set din_scripts_abs = `pwd`
cd -

# ----------------------------------------------------------------------
# create and enter the output directory
mkdir -p $dout_epi
cd $dout_epi

# ----------------------------------------------------------------------
# and create the datasets
tcsh -x $din_scripts_abs/run.1.make.all.dsets.tcsh $subj_dicom_abs \
     |& tee out.run.1.make.all.dsets

