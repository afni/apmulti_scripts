
# copy DIMON output to NIFTI format with BIDS-ish naming
# 
# input:  Dimon output 'func' dir
# output: demo output 'func' dir

set prog = `basename $0`
if ( $#argv != 2 ) then
   echo "** usage: $prog DICOM_func_dir NEW_DIR"
   exit 1
endif

# input vars
set din_dicom   = $1
set dout_func   = $2

# ----------------------------------------------------------------------
# check input dir, get full path, and (possibly) make output dir

# din_dicom must be a func dir (and allow for '.')
if ( $din_dicom == "." ) then
   set tail = $PWD:t
else
   set tail = $din_dicom:t
endif

if ( ! -d $din_dicom || $tail != "func") then
   echo "** missing input DICOM dir $din_dicom, or not a 'func' path"
   exit 1
endif

mkdir -p $dout_func


# ----------------------------------------------------------------------
# general output vars

set sid      = sub-001_ses-01
set task     = task-naming-1
set suffix   = bold.nii.gz

# ----------------------------------------------------------------------
# copy asset and blip dsets

set rname    = run-1
set ename    = echo-1

3dcopy ${din_dicom}/epi.r02.asset+orig   \
       ${dout_func}/${sid}_acq-asset_${suffix}

3dcopy ${din_dicom}/epi.r03.blip+orig    \
       ${dout_func}/${sid}_acq-blip_dir-opp_run-1_${suffix}

3dcopy ${din_dicom}/epi.r04.blip.fwd.chan2+orig   \
       ${dout_func}/${sid}_acq-blip_dir-match_run-1_${suffix}

# ----------------------------------------------------------------------
# naming

set task = naming
set in_runs = ( 04 05 06 07 )
set iind = 1
foreach tver ( 1 2 )
  foreach run ( 1 2 )
    set irun = $in_runs[$iind]
    @ iind += 1

    foreach eind ( 1 2 3 )
      3dcopy ${din_dicom}/epi.r$irun.${task}_${tver}.${run}_chan_00${eind}+orig   \
             ${dout_func}/${sid}_task-${task}-${tver}_run-${run}_echo-${eind}_${suffix}
    end
  end
end

# ----------------------------------------------------------------------
# recog

set task = recog
set in_runs = ( 08 09 )
set iind = 1
foreach tver ( 1 2 )
  foreach run ( 1 )
    set irun = $in_runs[$iind]
    @ iind += 1

    foreach eind ( 1 2 3 )
      3dcopy ${din_dicom}/epi.r$irun.${task}_${tver}_chan_00${eind}+orig   \
             ${dout_func}/${sid}_task-${task}-${tver}_run-${run}_echo-${eind}_${suffix}
    end
  end
end

# ----------------------------------------------------------------------
# rest

set task = rest
set in_runs = ( 11 )
set iind = 1
foreach run ( 1 )
    set irun = $in_runs[$iind]
    @ iind += 1

    foreach eind ( 1 2 3 )
      3dcopy ${din_dicom}/epi.r$irun.${task}_chan_00${eind}+orig   \
             ${dout_func}/${sid}_task-${task}_run-${run}_echo-${eind}_${suffix}
    end
end

