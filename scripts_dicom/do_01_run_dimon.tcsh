
# convert DICOM data into AFNI trees: datasets/anat,epi
# (and put physio files under 'physio' subdir)
# 
# 

# input vars
set din_dicom   = $1
set din_physio  = physio_pulse_respiration_traces  # under $din_dicom

# output vars
set dout_dimon  = dimon_work
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
set din_dicom_abs = `pwd`

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
# basic dirs ( single echo )
set dir_list = ( $dirs_basic )
set lab_list = ( $labs_basic )
foreach index ( `count -digits 1 1 $#dir_list` )
    set dir = $dir_list[$index]
    set dlab = `echo $dir | cut -b6-`
    set label = $lab_list[$index]

    Dimon -infile_pat $din_dicom/$dir/'*.dcm'   \
          -gert_create_dataset                  \
          -save_details DET.$dir                \
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

    Dimon -infile_pat $din_dicom/$dir/'*.dcm'   \
          -gert_create_dataset                  \
          -save_details DET.$dir                \
          -num_chan 3 -sort_method geme_index   \
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
\cp -rp $din_dicom_abs/$din_physio physio

# ----------------------------------------------------------------------
# cleanup dimon files
\mkdir $dout_dimon
\mv DET.* GERT_Reco* dimon.files* $dout_dimon

