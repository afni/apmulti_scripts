#!/usr/bin/env tcsh

# Create new data tree for publishing, all under:
#     apmulti_root
# Copy anat dset and DICOM trees into it, along with
# optional FS and SSW results.

# ===========================================================================
# main vars to possibly modify

# ----------------------------------------
# subject ID (for output)
set subj  = sub-004
set ses   = ses-01

# ----------------------------------------
# top-level input and output dirs

# dir contains all scripts (git tree or copy)
set din_scripts = apmulti_scripts/apmulti_root

# note DICOM root and task list file (DICOM files, possible FS/SSW output)
set din_dicom = apmulti_data/${subj}/${ses}
set task_file = ${din_dicom}/task.dirs.txt

# root of tree (to possibly distribute)
set dout_aproot = apmulti_root

# ----------------------------------------
# find anat and set vars (orig and new)
set din_anat = `\grep anat $task_file | awk '{print $1}'`
if ( $status ) then
    echo "failed to find anat dir from ${task_file}"
    exit 1
endif
set din_anat = ${din_dicom}/${din_anat}
set anat_in  = ${din_anat}/anat_reface.nii.gz
set anat_out = ${subj}_${ses}_mprage_run-1_T1w.nii.gz

# ----------------------------------------
# (optional) SSW and FreeSurfer results
set din_ssw     = ${din_anat}/ssw_results
set din_suma    = ${din_anat}/group_fs/$subj/SUMA
 
# ===========================================================================
# verify inputs

# ----------------------------------------------------------------------
# check scripts dir and anatomical input
if ( ! -d $din_scripts/scripts_desktop || ! -f $anat_in ) then
   echo "** missing main input: $din_scripts/scripts_desktop or $din_anat"
   exit 1
endif

# SSW and SUMA are optional
if ( ! -d $din_ssw || ! -d $din_suma ) then
   echo "note: missing SSW or SUMA dir, $din_ssw or $din_suma"
   echo "      (they will be skipped)"
endif

# ===========================================================================
# get to work

# init main directories (if not already present)
\mkdir -p $dout_aproot
\mkdir -p $dout_aproot/logs

# apmulti_dicom
\mkdir -p $dout_aproot/apmulti_dicom/data_00_dicom/$subj
\mkdir -p $dout_aproot/apmulti_dicom/logs

# apmulti_demo
\mkdir -p $dout_aproot/apmulti_demo/data_00_basic/$subj/$ses
\mkdir -p $dout_aproot/apmulti_demo/data_12_fs/$subj
\mkdir -p $dout_aproot/apmulti_demo/data_13_ssw
\mkdir -p $dout_aproot/apmulti_demo/logs

# ----------------------------------------------------------------------
# copy the scripts scripts in (dirs match under apmulti_root)
\cp -rp $din_scripts/* $dout_aproot

# ----------------------------------------------------------------------
# apmulti_demo: copy anatomical

set dout_subj = $dout_aproot/apmulti_demo/data_00_basic/$subj/$ses

\mkdir -p $dout_aproot/apmulti_demo/data_00_basic/$subj/$ses/anat
3dcopy $anat_in $dout_subj/anat/$anat_out
nifti_tool -rm_ext ALL -overwrite -infile $dout_subj/anat/$anat_out

# and copy a corresponding png file
if ( -f ${din_anat}/anat_02_anon.face.sag.png ) then
   cp ${din_anat}/anat_02_anon.face.sag.png \
      $dout_subj/anat/${subj}_${ses}_mprage_run-1_T1w_face-sag.png
endif

# ----------------------------------------------------------------------
# apmulti_demo: copy SSW and SUMA results
if ( -d $din_ssw ) then
   \cp -rp $din_ssw $dout_aproot/apmulti_demo/data_13_ssw/$subj
endif

if ( -d $din_suma ) then
   \cp -rp $din_suma $dout_aproot/apmulti_demo/data_12_fs/$subj
endif


# ----------------------------------------------------------------------
# apmulti_dicom: copy DICOM data

# cp is appropriate, but a pre-made copy to mv is faster to test
if ( ! -d $dout_aproot/apmulti_dicom/data_00_dicom/$subj/$ses ) then
   \mkdir -p $dout_aproot/apmulti_dicom/data_00_dicom/$subj/$ses
   rsync -avq --exclude 'ssw_results*'                               \
              --exclude group_fs                                     \
              --exclude physio_pulse_respiration_traces.orig         \
              $din_dicom/                                            \
              $dout_aproot/apmulti_dicom/data_00_dicom/$subj/$ses/
endif

