#!/usr/bin/env tcsh

# AP DRAFT CMD: Ex 1, just some warping+blip corr, including regress for HTML

# Process a single subj+ses pair.  Run this script in
# apmulti_demo/scripts/, via the corresponding run_*tcsh script.

# --------------------------------------------------------------------------
# top level definitions (constant across demo)
# ---------------------------------------------------------------------------

# labels
set subj           = $1
set ses            = $2
set ap_label       = 41_ap_se_b

set template       = MNI152_2009_template_SSW.nii.gz 

# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw
set dir_physio     = ${dir_inroot}/data_14_physio
set dir_ap         = ${dir_inroot}/data_${ap_label}

# subject directories
set sdir_basic     = ${dir_basic}/${subj}/${ses}
set sdir_epi       = ${sdir_basic}/func
set sdir_fs        = ${dir_fs}/${subj}/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj}/${ses}
set sdir_physio    = ${dir_physio}/${subj}/${ses}
set sdir_ap        = ${dir_ap}/${subj}/${ses}

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

setenv AFNI_COMPRESSOR GZIP

# dataset inputs
set dsets_epi     = ( ${sdir_epi}/${subj}_${ses}_task-rest_*_echo-2_bold.nii* )

set anat_orig     = ${sdir_basic}/anat/${subj}_${ses}*T1w*.nii*

set epi_forward   = "${sdir_epi}/${subj}_${ses}_acq-blip_dir-match_run-1_bold.nii.gz[0]"
set epi_reverse   = "${sdir_epi}/${subj}_${ses}_acq-blip_dir-opp_run-1_bold.nii.gz[0]"

set anat_cp       = ${sdir_ssw}/anatSS.${subj}.nii
set anat_skull    = ${sdir_ssw}/anatU.${subj}.nii

set dsets_NL_warp = ( ${sdir_ssw}/anatQQ.${subj}.nii         \
                      ${sdir_ssw}/anatQQ.${subj}.aff12.1D    \
                      ${sdir_ssw}/anatQQ.${subj}_WARP.nii  )

set roi_all_2009  = ${sdir_suma}/aparc.a2009s+aseg_REN_all.nii.gz
set roi_FSvent    = ${sdir_suma}/fs_ap_latvent.nii.gz
set roi_FSWe      = ${sdir_suma}/fs_ap_wm.nii.gz

# control variables
set nt_rm         = 4
set blur_size     = 5
set final_dxyz    = 3      # can test against inputs
set cen_motion    = 0.2
set cen_outliers  = 0.05

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

set ap_cmd = ${sdir_ap}/ap.cmd.${subj}

\mkdir -p ${sdir_ap}

# write AP command to file
cat <<EOF >! ${ap_cmd}

# The 'regress' block is included here just to generate the APQC HTML

afni_proc.py                                                            \
     -subj_id                  ${subj}                                  \
     -blocks                   despike tshift align volreg regress      \
     -copy_anat                ${anat_cp}                               \
     -anat_has_skull           yes                                      \
     -dsets                    ${dsets_epi}                             \
     -align_opts_aea           -cost lpc+ZZ -giant_move                 \
     -blip_forward_dset        "${epi_forward}"                         \
     -blip_reverse_dset        "${epi_reverse}"                         \
     -volreg_align_to          MIN_OUTLIER                              \
     -volreg_align_e2a                                                  \
     -volreg_warp_dxyz         ${final_dxyz}                            \
     -html_review_style        pythonic 

EOF

cd ${sdir_ap}

# execute AP command to make processing script
tcsh -xef ${ap_cmd} |& tee output.ap.cmd.${subj}

set ecode = ${status}

if ( ! ${ecode} ) then
   # execute the proc script, saving text info
   time tcsh -xef proc.${subj} |& tee output.proc.${subj}
endif

set ecode = ${status}
if ( ${ecode} ) then
    echo "++ FAILED AP: ${ap_label}"
else
    echo "++ FINISHED AP: ${ap_label}"
endif

# ---------------------------------------------------------------------------

exit ${ecode}
