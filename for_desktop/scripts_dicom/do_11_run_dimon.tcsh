#!/usr/bin/env tcsh

# convert DICOM data into AFNI EPI datasets
# (and put physio files under 'physio' subdir)

# This should be run form apmulti_dicom or the scripts directory.

# --------------------------------------------------
# main data vars
set din_root    = apmulti_dicom
set din_droot   = data_00_dicom
set dout_droot  = data_11_AFNI_EPI
set subj        = sub-001
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
set epi_prefix  = epi
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

set dirs_skip  = ( mr_0001 )
set dirs_basic = ( mr_000[2-3] )          # asset, reverse blip
set labs_basic = ( asset blip )

# directory and matched label scripts
set dirs_ME    = ( mr_000[4-9] mr_0011 )
set labs_ME    = ( naming_{1.1,1.2,2.1,2.2} recog_{1,2} rest )

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
set dir_list = ( $dirs_basic )
set lab_list = ( $labs_basic )
foreach index ( `count -digits 1 1 $#dir_list` )
    set dir = $dir_list[$index]
    set dlab = `echo $dir | cut -b6-`
    set label = $lab_list[$index]

    Dimon -infile_pat $din_dicom_path/$dir/'*.dcm'    \
          -gert_create_dataset                        \
          -save_details DET.$dir                      \
          -gert_to3d_prefix $epi_prefix.r$dlab.$label
end

# ----------------------------------------------------------------------
# multi-echo dirs
set dir_list = ( $dirs_ME )
set lab_list = ( $labs_ME )
foreach index ( `count -digits 1 1 $#dir_list` )
    set dir = $dir_list[$index]
    set dlab = `echo $dir | cut -b6-`
    set label = $lab_list[$index]

    Dimon -infile_pat $din_dicom_path/$dir/'*.dcm'    \
          -gert_create_dataset                        \
          -save_details DET.$dir                      \
          -num_chan 3 -sort_method geme_index         \
          -gert_to3d_prefix $epi_prefix.r$dlab.$label
end

# ----------------------------------------------------------------------
# possibly try to match 0,0,0 across these oblique datasets
# (do 1 at a time to keep history short)
if ( $do_recenter ) then
   foreach epi ( $epi_prefix.*.HEAD )
      3drefit -oblique_recenter $epi
   end
endif

# ----------------------------------------------------------------------
# fake a blip forward dataset by copying 10 vols from run 04 chan 2
3dTcat -prefix $epi_prefix.r04.blip.fwd.chan2 \
              "$epi_prefix.r04.naming_1.1_chan_002+orig[0..9]"

# ----------------------------------------------------------------------
# copy physio tree here
\cp -rp $din_dicom_path/$din_physio physio

# ----------------------------------------------------------------------
# cleanup dimon files
\mkdir -p dimon_work
\mv DET.* GERT_Reco* dimon.files* dimon_work

