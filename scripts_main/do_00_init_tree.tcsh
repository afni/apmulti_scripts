#!/usr/bin/env tcsh

# Create new data tree for publishing.
# Copy anat dset and DICOM trees into it.

# ===========================================================================
# main vars to possibly modify

# ----------------------------------------
# top-level input and output dirs

# dir contains all scripts (git tree or copy)
set din_scripts = apmulti_scripts

# contains DICOM images and extras (anat, FS and SSW output)
set din_dicom   = NvR_S02
set din_extras  = $din_dicom/mr_0010_proc

# root of tree (to possibly distribute)
set dout_aproot = apmulti_root

# ----------------------------------------
# anat vars (orig and new)
set anat_in     = ${din_extras}/anat_02_anon.reface.nii.gz
set anat_out    = ${subj}_${ses}_mprage_run-1_T1w.nii.gz

# ----------------------------------------
# SSW and FreeSurfer results
set din_ssw     = ${din_extras}/ssw_results_NvR_S02
set din_suma    = ${din_extras}/group_fs/sub_02/SUMA
 
# ----------------------------------------
# subject ID (for output)
set subj  = sub-001
set ses   = ses-01

# ===========================================================================
# verify inputs

# ----------------------------------------------------------------------
# be sure input dirs exist
if ( ! -d $din_scripts/scripts_main || ! -d $din_extras ) then
   echo "** missing main input dirs, $din_scripts/scripts_main or $din_extras"
   exit 1
endif

if ( ! -d $din_ssw || ! -d $din_suma ) then
   echo "** missing SSW or SUMA dir, $din_ssw or $din_suma"
   exit 1
endif

# ===========================================================================
# get to work

# init main directories (if not already present)
mkdir -p $dout_aproot

# apmulti_dicom
mkdir -p $dout_aproot/apmulti_dicom/scripts
mkdir -p $dout_aproot/apmulti_dicom/data_00_dicom/$subj

# apmulti_demo
mkdir -p $dout_aproot/apmulti_demo/data_00_input/$subj/$ses
mkdir -p $dout_aproot/apmulti_demo/data_12_fs/$subj
mkdir -p $dout_aproot/apmulti_demo/data_13_ssw


# ----------------------------------------------------------------------
# copy the main scripts in
cp -rp $din_scripts/scripts_main $dout_aproot/scripts


# ----------------------------------------------------------------------
# apmulti_demo: copy anatomical
mkdir -p $dout_aproot/apmulti_demo/data_00_basic/$subj/$ses/anat
3dcopy $din_dicom/mr_0010/NvR_S02_anat_NoSkull+orig \
       $dout_aproot/apmulti_demo/data_00_basic/$subj/$ses/anat/$anat_out
nifti_tool -rm_ext ALL -overwrite -infile \
       $dout_aproot/apmulti_demo/data_00_basic/$subj/$ses/anat/$anat_out

# ----------------------------------------------------------------------
# apmulti_demo: copy SSW and SUMA results
cp -rp $din_suma $dout_aproot/apmulti_demo/data_02_fs/$subj
cp -rp $din_ssw $dout_aproot/apmulti_demo/data_03_ssw/$subj


# ----------------------------------------------------------------------
# apmulti_dicom: copy DICOM scripts and data

if ( ! -f $dout_aproot/apmulti_dicom/scripts/run.1.make.all.dsets ) then
   cp -p $din_scripts/scripts_dimon/run.* $dout_aproot/apmulti_dicom/scripts
endif

# cp is appropriate, but a pre-made copy to mv is faster to test
if ( ! -d $dout_aproot/apmulti_dicom/data_00_basic/$subj/$ses ) then
   cp -rp $din_dicom $dout_aproot/apmulti_dicom/data_00_basic/$subj/$ses
endif

