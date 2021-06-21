
# copy DIMON output to NIFTI format with BIDS-ish naming
# (and include physio)
# 
# input:  Dimon output 'func' dir
# output: demo output 'func' dir

set din_root    = apmulti_dicom
set din_droot   = data_11_AFNI_EPI
set dout_droot  = data_12_NIFTI_EPI
set subj        = sub-001
set ses         = ses-01


# local paths to data
set din_subj    = $din_droot/$subj/$ses
set dout_subj   = $dout_droot/$subj/$ses

# ----------------------------------------------------------------------
# check input dir, get full path, and (possibly) make output dir

# might be common to run from scripts, but start up one dir
if ( $PWD:t == "scripts" ) then
   cd ..
endif
if ( $PWD:t != $din_root ) then
   echo "** should be run from $din_root/scripts"
   exit 1
endif

if ( ! -d $din_subj ) then
   echo "** missing subject AFNI EPI dir $din_subj"
   exit 1
endif

mkdir -p $dout_subj


# ----------------------------------------------------------------------
# general input/output vars

set sid      = ${subj}_${ses}
set task     = task-naming-1
set suffix   = bold.nii.gz

set NIH_physio = epiRTnih_scan

# ----------------------------------------------------------------------
# copy asset and blip dsets

set rname    = run-1
set ename    = echo-1

3dcopy ${din_subj}/epi.r02.asset+orig   \
       ${dout_subj}/${sid}_acq-asset_${suffix}

3dcopy ${din_subj}/epi.r03.blip+orig    \
       ${dout_subj}/${sid}_acq-blip_dir-opp_run-1_${suffix}

3dcopy ${din_subj}/epi.r04.blip.fwd.chan2+orig   \
       ${dout_subj}/${sid}_acq-blip_dir-match_run-1_${suffix}

# ======================================================================
# the following (task and rest) EPI dsets include physio files
# ======================================================================

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
      set ein  = epi.r$irun.${task}_${tver}.${run}_chan_00${eind}+orig
      set eout = ${sid}_task-${task}-${tver}_run-${run}_echo-${eind}_${suffix}
      3dcopy ${din_subj}/${ein} ${dout_subj}/${eout}
    end

    # and copy physio
    foreach ptype ( ECG Resp )
       set pin = ${ptype}_${NIH_physio}_00${irun}.txt
       set pout = ${sid}_task-${task}-${tver}_run-${run}_physio-$ptype.txt
       cp -v ${din_subj}/physio/${pin} ${dout_subj}/${pout}
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
      set ein  = epi.r$irun.${task}_${tver}_chan_00${eind}+orig
      set eout = ${sid}_task-${task}-${tver}_run-${run}_echo-${eind}_${suffix}
      3dcopy ${din_subj}/${ein} ${dout_subj}/${eout}
    end

    # and copy physio
    foreach ptype ( ECG Resp )
       set pin = ${ptype}_${NIH_physio}_00${irun}.txt
       set pout = ${sid}_task-${task}-${tver}_run-${run}_physio-$ptype.txt
       cp -v ${din_subj}/physio/${pin} ${dout_subj}/${pout}
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
      set ein  = epi.r$irun.${task}_chan_00${eind}+orig
      set eout = ${sid}_task-${task}_run-${run}_echo-${eind}_${suffix}
      3dcopy ${din_subj}/${ein} ${dout_subj}/${eout}
    end

    # and copy physio
    foreach ptype ( ECG Resp )
       set pin = ${ptype}_${NIH_physio}_00${irun}.txt
       set pout = ${sid}_task-${task}-${tver}_run-${run}_physio-$ptype.txt
       cp -v ${din_subj}/physio/${pin} ${dout_subj}/${pout}
    end
end

