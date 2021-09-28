#!/usr/bin/env tcsh

# convert DICOM data into AFNI EPI datasets
# (and put physio files under 'physio' subdir)

# This should be run form apmulti_dicom or the scripts directory.

# --------------------------------------------------
# main data vars
set din_root    = apmulti_dicom
set din_droot   = data_00_dicom
set dout_droot  = data_11_AFNI_EPI
set subj        = sub-004
set ses         = ses-01

# --------------------------------------------------
# might be common to run from scripts, but start up one dir
if ( $PWD:t == "scripts" ) then
   cd ..
endif
if ( $PWD:t != $din_root ) then
   echo "** should be run from $din_root/scripts"
   exit 1
endif

# data source dirs
set din_dicom   = $din_droot/$subj/$ses
set din_physio  = physio_pulse_respiration_traces  # under $din_dicom

# output vars
set dout_dimon  = $dout_droot/$subj/$ses
set do_recenter = 1        # keep off to match RT and dimon output

# ----------------------------------------------------------------------
# check input dir

if ( ! -d $din_dicom/$din_physio ) then
   echo "** missing input DICOM/physio dir $din_dicom$din_physio"
   exit 1
endif

# ===========================================================================
# DICOM
# ===========================================================================

# ----------------------------------------------------------------------
# works on all but 01 (localizer), 02 (asset calib), 10 (anat NIFTI)
# dir 03 is single echo blip
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# associate labels with directory names
# (go to DICOM dir and return)

cd $din_dicom
set din_dicom_path = `pwd`

# directory and matched label scripts
set task_file  = task.dirs.txt
set task_anat  = ( anat )
set task_ME    = ( rest naming{1,2}_run{1,2} recog_run{1,2} )
set task_SE    = ( blip )

if ( ! -f $task_file ) then
   echo "** missgin task_file $task_file for subj $subj"
   exit 1
endif

# assign dirs corresponding to tasks
set dir_anat = `\grep $task_anat $task_file | awk '{print $1}'`
set dirs_ME  = ()
set dirs_SE  = ()

# set dirs for ME and other
foreach task ( $task_ME )
   set tdir = `awk "/$task/"' {print $1}' $task_file`
   set dirs_ME = ( $dirs_ME $tdir )
   if ( ! -d $tdir ) then
      echo "** subj $subj : missing task dir '$tdir' for task '$task'"
      exit 1
   endif
end
foreach task ( $task_SE )
   set tdir = `awk "/$task/"' {print $1}' $task_file`
   set dirs_SE = ( $dirs_SE $tdir )
   echo "== tdir = '$tdir'"
   if ( ! -d $tdir ) then
      echo "** subj $subj : missing task dir '$tdir' for task '$task'"
      exit 1
   endif
end

cd -


# ----------------------------------------------------------------------
# I thought we were not supposed to need this set...
setenv AFNI_SLICE_SPACING_IS_GAP NO

# ----------------------------------------------------------------------
# now that we have a full path to the input, create and enter output dir
\mkdir -p $dout_dimon
cd $dout_dimon

# ----------------------------------------------------------------------
# basic dirs ( single echo )
set dir_list = ( $dirs_SE )
set lab_list = ( $task_SE )
foreach index ( `count -digits 1 1 $#dir_list` )
    set dir = $dir_list[$index]
    set label = $lab_list[$index]

    Dimon -infile_pat $din_dicom_path/$dir/'*.dcm'    \
          -gert_create_dataset                        \
          -save_details DET.$dir                      \
          -gert_to3d_prefix ${subj}_task-$label
end

# ----------------------------------------------------------------------
# multi-echo dirs
set dir_list = ( $dirs_ME )
set lab_list = ( $task_ME )
foreach index ( `count -digits 1 1 $#dir_list` )
    set dir = $dir_list[$index]
    set label = $lab_list[$index]

    Dimon -infile_pat $din_dicom_path/$dir/'*.dcm'    \
          -gert_create_dataset                        \
          -save_details DET.$dir                      \
          -num_chan 3 -sort_method geme_index         \
          -gert_to3d_prefix ${subj}_task-$label

    set scan = `echo $dir | awk -F_ '{print $2}'`
    foreach ptype ( ECG Resp )
       cp -pv $din_dicom_path/$din_physio/${ptype}_epiRTnih_scan_${scan}.txt \
              ${subj}_task-${label}_physio-$ptype.txt
    end
end

# ----------------------------------------------------------------------
# possibly try to match 0,0,0 across these oblique datasets
# (do 1 at a time to keep history short)
if ( $do_recenter ) then
   foreach epi ( ${subj}*.HEAD )
      3drefit -oblique_recenter $epi
   end
endif

# ----------------------------------------------------------------------
# fake a blip forward dataset by copying 10 vols from run 04 chan 2
3dTcat -prefix ${subj}_task-blip-fwd_chan_002+orig  \
               ${subj}_task-naming1_run1_chan_002+orig.HEAD'[0..9]'

# ----------------------------------------------------------------------
# and copy task file, just to have
\cp -p $din_dicom_path/$task_file .

# ----------------------------------------------------------------------
# cleanup dimon files
\mkdir -p dimon_work
\mv DET.* GERT_Reco* dimon.files* dimon_work

