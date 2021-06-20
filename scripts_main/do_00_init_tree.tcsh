#!/usr/bin/env tcsh

# Create new data tree for publishing.
# Copy anat dset and DICOM trees into it.

# ===========================================================================
# main vars to possibly modify

# ----------------------------------------
# subject ID (for output)
set subj  = sub-001
set ses   = ses-01

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
\mkdir -p $dout_aproot

# apmulti_dicom
\mkdir -p $dout_aproot/apmulti_dicom/data_00_dicom/$subj

# apmulti_demo
\mkdir -p $dout_aproot/apmulti_demo/data_00_input/$subj/$ses
\mkdir -p $dout_aproot/apmulti_demo/data_12_fs/$subj
\mkdir -p $dout_aproot/apmulti_demo/data_13_ssw


# ----------------------------------------------------------------------
# copy the scripts scripts in
\cp -rp $din_scripts/scripts_main $dout_aproot/scripts
\cp -rp $din_scripts/scripts_dicom $dout_aproot/apmulti_dicom/scripts
\cp -rp $din_scripts/scripts_demo $dout_aproot/apmulti_demo/scripts


# ----------------------------------------------------------------------
# apmulti_demo: copy anatomical

set dout_subj = $dout_aproot/apmulti_demo/data_00_basic/$subj/$ses

\mkdir -p $dout_aproot/apmulti_demo/data_00_basic/$subj/$ses/anat
3dcopy $anat_in $dout_subj/anat/$anat_out
nifti_tool -rm_ext ALL -overwrite -infile $dout_subj/anat/$anat_out

# ----------------------------------------------------------------------
# apmulti_demo: copy SSW and SUMA results
\cp -rp $din_suma $dout_aproot/apmulti_demo/data_12_fs/$subj
\cp -rp $din_ssw $dout_aproot/apmulti_demo/data_13_ssw/$subj


# ----------------------------------------------------------------------
# apmulti_dicom: copy DICOM data

# cp is appropriate, but a pre-made copy to mv is faster to test
if ( ! -d $dout_aproot/apmulti_dicom/data_00_basic/$subj/$ses ) then
   \mkdir -p $dout_aproot/apmulti_dicom/data_00_basic/$subj/$ses
   rsync -avq --exclude mr_0010_proc $din_dicom \
         $dout_aproot/apmulti_dicom/data_00_basic/$subj/$ses/
endif

