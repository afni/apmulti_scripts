#!/usr/bin/env tcsh

# Create new data tree for publishing.
# Copy anat dset and DICOM trees into it.

set rootd = apmulti_root
set subj  = sub-001
set ses   = ses-01

# contains scripts for Dimon
set din_scripts = git/apmulti_scripts

# contains DICOM images
set din_dicom = NvR_S02.clean
set anat_name = ${subj}_${ses}-mprage_run-1_T1w.nii.gz

# SSW and FreeSurfer results
set din_ssw   = APMULTI/ssw_results_NvR_S02
# ** todo : we might want to copy entire FS output tree
set din_suma  = APMULTI/SUMA
 
# ----------------------------------------------------------------------
# be sure input dirs exist
if ( ! -d $din_scripts/scripts_preproc || ! -d $din_dicom ) then
   echo "** missing main input dirs, $din_scripts/scripts_preproc or $din_dicom"
   exit 1
endif

if ( ! -d $din_ssw || ! -d $din_suma ) then
   echo "** missing SSW or SUMA dir, $din_ssw or $din_suma"
   exit 1
endif

# ----------------------------------------------------------------------
# init main directories (if not already present)
mkdir -p $rootd

mkdir -p $rootd/scripts/log

# apmulti_demo
mkdir -p $rootd/apmulti_demo/scripts
mkdir -p $rootd/apmulti_demo/data_00_basic/$subj/$ses
mkdir -p $rootd/apmulti_demo/data_02_fs/$subj
mkdir -p $rootd/apmulti_demo/data_03_ssw

# apmulti_dicom (do not make $ses)
mkdir -p $rootd/apmulti_dicom/scripts
mkdir -p $rootd/apmulti_dicom/data_00_basic/$subj


# ----------------------------------------------------------------------
# copy the main scripts in
cp -p $din_scripts/scripts_preproc/*.tcsh $rootd/scripts


# ----------------------------------------------------------------------
# apmulti_demo: copy anatomical
mkdir -p $rootd/apmulti_demo/data_00_basic/$subj/$ses/anat
3dcopy $din_dicom/mr_0010/NvR_S02_anat_NoSkull+orig \
       $rootd/apmulti_demo/data_00_basic/$subj/$ses/anat/$anat_name
nifti_tool -rm_ext ALL -overwrite -infile \
       $rootd/apmulti_demo/data_00_basic/$subj/$ses/anat/$anat_name

# ----------------------------------------------------------------------
# apmulti_demo: copy SSW and SUMA results
cp -rp $din_suma $rootd/apmulti_demo/data_02_fs/$subj
cp -rp $din_ssw $rootd/apmulti_demo/data_03_ssw/$subj


# ----------------------------------------------------------------------
# apmulti_dicom: copy DICOM scripts and data

if ( ! -f $rootd/apmulti_dicom/scripts/run.1.make.all.dsets ) then
   cp -p $din_scripts/scripts_dimon/run.* $rootd/apmulti_dicom/scripts
endif

# cp is appropriate, but a pre-made copy to mv is faster to test
if ( ! -d $rootd/apmulti_dicom/data_00_basic/$subj/$ses ) then
   cp -rp $din_dicom $rootd/apmulti_dicom/data_00_basic/$subj/$ses
endif

