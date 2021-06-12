#!/bin/tcsh

#----------------------------------------------------------------------
# works on all but 01 (localizer), 02 (asset calib), 10 (anat NIFTI)
# dir 03 is single echo blip
#----------------------------------------------------------------------

set outdir = dimon.output

#----------------------------------------------------------------------
# associate labels with directory names
set dirs_skip  = ( mr_0001 )
set dirs_basic = ( mr_000[2-3] )          # asset, reverse blip
set labs_basic = ( asset blip )

set dirs_ME    = ( mr_000[4-9] mr_0011 )  # naming1, 1, naming2, 2, recog1, 2, rest
set labs_ME    = ( naming_{1.1,1.2,2.1,2.2} recog_{1,2} rest )

set dirs_anat  = ( mr_0010 )

#----------------------------------------------------------------------
# check, create and enter output dir
if ( -d $outdir ) then
   echo "** already have output dir $outdir, refusing to proceed"
   exit 1
endif
mkdir $outdir

cd $outdir

#----------------------------------------------------------------------
# I thought we were not supposed to need this set...
setenv AFNI_SLICE_SPACING_IS_GAP NO

#----------------------------------------------------------------------
# basic dirs ( single echo )
set dir_list = ( $dirs_basic )
set lab_list = ( $labs_basic )
foreach index ( `count -digits 1 1 $#dir_list` )
    set dir = $dir_list[$index]
    set dlab = `echo $dir | cut -b6-`
    set label = $lab_list[$index]

    Dimon -infile_pat ../$dir/'*.dcm'           \
          -gert_create_dataset                  \
          -save_details DET.$dir                \
          -gert_to3d_prefix epi.r$dlab.$label
end

#----------------------------------------------------------------------
# multi-echo dirs
set dir_list = ( $dirs_ME )
set lab_list = ( $labs_ME )
foreach index ( `count -digits 1 1 $#dir_list` )
    set dir = $dir_list[$index]
    set dlab = `echo $dir | cut -b6-`
    set label = $lab_list[$index]

    Dimon -infile_pat ../$dir/'*.dcm'           \
          -gert_create_dataset                  \
          -save_details DET.$dir                \
          -num_chan 3 -sort_method geme_index   \
          -gert_to3d_prefix epi.r$dlab.$label
end

#----------------------------------------------------------------------
# anat
set dir = $dirs_anat
cp -pv ../$dir/* . 

