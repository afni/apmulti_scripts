#!/usr/bin/env tcsh

# AP: basic, single echo rest
# For AP paper, ex 3

# Process a single subj+ses pair.  Run this script in
# apmulti_demo/scripts/, via the corresponding run_*tcsh script.

# --------------------------------------------------------------------------
# top level definitions (constant across demo)
# ---------------------------------------------------------------------------

# labels
set subj           = $1
set ses            = $2
set ap_label       = 40_ap_se

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

set anat_cp       = ${sdir_ssw}/anatSS.${subj}.nii
set anat_skull    = ${sdir_ssw}/anatU.${subj}.nii

set dsets_NL_warp = ( ${sdir_ssw}/anatQQ.${subj}.nii         \
                      ${sdir_ssw}/anatQQ.${subj}.aff12.1D    \
                      ${sdir_ssw}/anatQQ.${subj}_WARP.nii  )

set roi_all_2009    = ${sdir_suma}/aparc.a2009s+aseg_REN_all.nii.gz
set roi_FSvent      = ${sdir_suma}/fs_ap_latvent.nii.gz
set roi_FSWe        = ${sdir_suma}/fs_ap_wm.nii.gz
set roi_gmrois_2000 = ${sdir_suma}/aparc+aseg_REN_gmrois.nii.gz
set roi_gmrois_2009 = ${sdir_suma}/aparc.a2009s+aseg_REN_gmrois.nii.gz

set physio_prefix = ${sdir_physio}/${subj}_${ses}
set physio_regs   = ${physio_prefix}_task-rest_run-1_physio.slibase.1D

# control variables
set nt_rm         = 4
##set blur_size     = 5    # no blurring here
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

# no blur: ROI-based, volumetric
# use fanaticor with WMe and PC ventricles (both from FS)
# include physio regressors
# include GM-ROIs from FS (both 2000 and 2009 parc)

# we do NOT include bandpassing here (see comments in text

afni_proc.py                                                            \
     -subj_id                  ${subj}                                  \
     -blocks despike ricor tshift align tlrc volreg mask scale regress  \
     -radial_correlate_blocks  tcat volreg                              \
     -copy_anat                ${anat_cp}                               \
     -anat_has_skull           no                                       \
     -anat_follower            anat_w_skull anat ${anat_skull}          \
     -anat_follower_ROI        aaseg        anat ${roi_all_2009}        \
     -anat_follower_ROI        aeseg        epi  ${roi_all_2009}        \
     -anat_follower_ROI        aagm09       anat ${roi_gmrois_2009}     \
     -anat_follower_ROI        aegm09       epi  ${roi_gmrois_2009}     \
     -anat_follower_ROI        aagm00       anat ${roi_gmrois_2000}     \
     -anat_follower_ROI        aegm00       epi  ${roi_gmrois_2000}     \
     -anat_follower_ROI        FSvent       epi  ${roi_FSvent}          \
     -anat_follower_ROI        FSWe         epi  ${roi_FSWe}            \
     -anat_follower_erode      FSvent FSWe                              \
     -dsets                    ${dsets_epi}                             \
     -tcat_remove_first_trs    ${nt_rm}                                 \
     -ricor_regs               ${physio_regs}                           \
     -ricor_regs_nfirst        ${nt_rm}                                 \
     -ricor_regress_method     per-run                                  \
     -align_opts_aea           -cost lpc+ZZ -giant_move -check_flip     \
     -tlrc_base                ${template}                              \
     -tlrc_NL_warp                                                      \
     -tlrc_NL_warped_dsets     ${dsets_NL_warp}                         \
     -volreg_align_to          MIN_OUTLIER                              \
     -volreg_align_e2a                                                  \
     -volreg_tlrc_warp                                                  \
     -volreg_warp_dxyz         ${final_dxyz}                            \
     -volreg_compute_tsnr      yes                                      \
     -mask_epi_anat            yes                                      \
     -regress_motion_per_run                                            \
     -regress_ROI_PC FSvent    3                                        \
     -regress_ROI_PC_per_run   FSvent                                   \
     -regress_make_corr_vols   aeseg FSvent                             \
     -regress_anaticor_fast                                             \
     -regress_anaticor_label   FSWe                                     \
     -regress_censor_motion    ${cen_motion}                            \
     -regress_censor_outliers  ${cen_outliers}                          \
     -regress_apply_mot_types  demean deriv                             \
     -regress_est_blur_epits                                            \
     -regress_est_blur_errts                                            \
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
