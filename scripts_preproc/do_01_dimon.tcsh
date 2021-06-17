#!/usr/bin/env tcsh

# Run Dimon to create datasets, and populate apmulti_demo tree with result.

set rootd       = apmulti_dicom
set subj        = sub-001
set ses         = ses-01

set bids_root   = ../apmulti_demo/data_00_basic

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
set subj_dicom_path = `pwd`
cd -

# note the full path to the scripts directory
cd $din_scripts
set din_scripts_path = `pwd`
cd -

# check and note the path for the BIDS output
if ( ! -d $bids_root ) then
   echo "** missing output root dir $bids_root"
   exit 1
endif
cd $bids_root
set bids_root_path = `pwd`
cd -

# ----------------------------------------------------------------------
# create and enter the Dimon output directory
mkdir -p $dout_epi
cd $dout_epi

# ----------------------------------------------------------------------
# run Dimon to create the datasets
tcsh -x $din_scripts_path/run.1.make.all.dsets.tcsh $subj_dicom_path \
     |& tee out.run.1.make.all.dsets.txt

# ----------------------------------------------------------------------
# copy Dimon EPI to BIDS-style NIFTI (from current to unmade func dir)
tcsh -x $din_scripts_path/run.2.copy.epi.tcsh   \
        .                                       \
        $bids_root_path/$subj/$ses/func         \
     |& tee out.run.2.copy.epi.txt

