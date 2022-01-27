# ===========================================================================
#
# Create a new realtime regression testing tree based a a single mr_XXXX
# directory.  
#
# input: a single mr directory (and correspondinng top-level variables)
#
# output:
#    - dicom dir for 12 vols of a single echo
#    - dicom dir for 12 vols of all 3 echoes
#    - results: run Dimon to create dets for all volumes ($total_vols)
#    - results: run Dimon to create dets for  12 volumes ($nvols)
#    - results: run AP on 237 volume data
#               (run InstaCorr and clusterize for ROI mask)
#    - results: run AP on  12 volume data
#               (get matching External volreg base from here)
#    - realtime results tree
#
# The realtime results tree will come with:
#    - (copied) input for RT tests:
#       - dicom file: 12 volumes of 1 echo
#       - dicom file: 12 volumes of 3 echoes
#       - extras:
#          - make.RT_extras.txt (how extras were made)
#          - volume registration dset (for test as External)
#          - alternate volume registration dset (multi-volume, to test)
#          - (5-value cluster) mask
#          - surfaces made from the clusters (for kicks)

# ----------------------------------------------------------------------
# start with directory that has single run of ME data
# (these would be altered for new data)
set mrdir = mr_0004
set nvols = 12
set nchan = 3
set odir_dicom = dicom_${nvols}_vols
set echo_times = ( 12.5 27.6 42.7 )
set total_vols = 237


# ===========================================================================
# get to work
# ===========================================================================

# counter for major steps
set index = 0

# ----------------------------------------------------------------------
# create complete results

@ index += 1
set odir_dimon = results.$index.dimon.$total_vols
mkdir $odir_dimon
cd $odir_dimon

Dimon                                  \
   -infile_pattern "../orig_data/$mrdir/*.dcm"   \
   -gert_create_dataset                \
   -save_details DET.$mrdir            \
   -num_chan $nchan                    \
   -sort_method geme_index             \
   -gert_to3d_prefix epi

cd ..

# ----------------------------------------------------------------------
# note the number of slices to grab
set nslices = `3dinfo -nk $odir_dimon/epi_chan_001+orig`
set ntslices = `ccalc -i "$nslices*$nvols"`


# ----------------------------------------------------------------------
# copy the slice files
mkdir -p $odir_dicom
cd $odir_dicom
set file_lists = ( ../$odir_dimon/dimon.files.* )

foreach list ( $file_lists )
    echo ++ copying $ntslices from $list
    cp -p `head -n $ntslices $list` .
end

# ---------------------
# also, get just echo 2
mkdir -p ../$odir_dicom.e2
set list = ../$odir_dimon/dimon.files.run.004.chan.002
cp -p `head -n $ntslices $list` ../$odir_dicom.e2

cd ..

# ======================================================================

# ----------------------------------------------------------------------
# now re-run Dimon on just the 12 vols

@ index += 1
set odir_dimon12 = results.$index.dimon.12
mkdir $odir_dimon12
cd $odir_dimon12

Dimon                                  \
   -infile_pattern "../$odir_dicom/*.dcm" \
   -gert_create_dataset                \
   -save_details DET.$mrdir            \
   -num_chan $nchan                    \
   -sort_method geme_index             \
   -gert_to3d_prefix epi.12

cd ..

# ======================================================================

# ----------------------------------------------------------------------
# now run afni_proc.py on the $total_vols vol dset
# (for registration comparison and such)

@ index += 1
set odir = results.$index.AP.$total_vols
mkdir $odir
cd $odir

set ddir = results.1.dimon.$total_vols

set subj = AP.$total_vols
# remove 2 TRs, so use 'first' for volreg
afni_proc.py                     \
   -subj_id $subj                \
   -blocks volreg mask combine regress \
   -dsets_me_run ../$ddir/epi_chan_*+orig.HEAD \
   -echo_times $echo_times       \
   -reg_echo 2                   \
   -tcat_remove_first_trs 2      \
   -volreg_align_to first        \
   -combine_method OC            \
   -html_review_style pythonic   \
 |& tee out.run.ap.txt

tcsh -xef proc.$subj |& tee output.proc.$subj

cd ..

# ======================================================================


# ----------------------------------------------------------------------
# now run afni_proc.py on the 12 vol dset
# (for registration comparison and such)

@ index += 1
set odir = results.$index.AP.12
mkdir $odir
cd $odir

# takes ~3 seconds w/out regress, takes ~25 with
set subj = AP.12
afni_proc.py                     \
   -subj_id $subj                \
   -blocks volreg mask combine regress \
   -dsets_me_run ../$odir_dimon12/epi.12_chan_*+orig.HEAD \
   -echo_times $echo_times       \
   -reg_echo 2                   \
   -volreg_align_to third        \
   -combine_method OC            \
   -html_review_style pythonic   \
 |& tee out.run.ap.txt

tcsh -xef proc.$subj |& tee output.proc.$subj


# ------------------------------
# init an RT_extras directory with the vr_base
mkdir -p ../RT_extras
cp -p $subj.results/vr_base+orig* ../RT_extras

cd ..

# ======================================================================

