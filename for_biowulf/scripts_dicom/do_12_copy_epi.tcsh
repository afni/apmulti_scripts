#!/usr/bin/env tcsh

# copy DIMON output to NIFTI format with BIDS-ish naming
# (and include physio)
# 
# input:  Dimon output 'func' dir
# output: demo output 'func' dir

set din_root    = apmulti_dicom
set din_droot   = data_11_AFNI_EPI
set dout_droot  = data_12_NIFTI_EPI
set subj        = sub-004
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
# copy blip dsets

set rname    = run-1
set ename    = echo-1

3dcopy ${din_subj}/${subj}_task-blip+orig \
       ${dout_subj}/${sid}_acq-blip_dir-opp_run-1_${suffix}

3dcopy ${din_subj}/${subj}_task-blip-fwd_chan_002+orig \
       ${dout_subj}/${sid}_acq-blip_dir-match_run-1_${suffix}

# ======================================================================
# the following (task and rest) EPI dsets include physio files
# ======================================================================

foreach file ( ${din_subj}/sub*.HEAD )
   # break into pieces, partitioned by _ (or +)
   set fshort = $file:t
   set fparts = ( `echo $fshort | tr _+ ' '` )
   echo "++ parsing $subj file $fshort"
   echo "   parts: $fparts"
   if ( $#fparts <  6 && $fparts[2] =~ task-blip* ) then
      echo "-- skipping already copied blip dataset"
      continue
   else if ( $#fparts != 6 ) then
      echo "** bad format for file $file"
      exit 1
   endif

   set ftask = $fparts[2]                    # task is okay
   set frun  = `echo $fparts[3] | cut -b4-`  # remove 'run'
   set chan  = `ccalc -i $fparts[5]`         # remove zero padding
   set fout = ${sid}_${ftask}_run-${frun}_echo-${chan}_${suffix}

   # main step: copy dataset to a new name
   echo 3dcopy ${file} ${dout_subj}/$fout
   3dcopy ${file} ${dout_subj}/$fout

   foreach ptype ( ECG Resp )
      set pin  = ${subj}_task-${ftask}_run${frun}_physio-${ptype}.txt
      set pout = ${sid}_${ftask}_run-${frun}_physio-${ptype}.txt
      if ( -f ${din_subj}/$pin ) then
         cp -pv ${din_subj}/${pin} ${dout_subj}/${pout}
      endif
   end
end

