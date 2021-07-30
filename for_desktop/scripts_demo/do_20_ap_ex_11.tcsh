#!/usr/bin/env tcsh

# ---------------------------------------------------------------------------
# basic, single echo rest, based on example 11
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# data and control variables
# ---------------------------------------------------------------------------

# labels
set label         = 0.ex11
set isubj         = NvR_S02

# directories
set dir_inroot    = ../NvR_S02.test
set dir_ssw       = ${dir_inroot}/ssw_results_NvR_S02
set dir_epi       = ${dir_inroot}/dimon.output
set dir_suma      = ${dir_inroot}/SUMA

# dataset inputs
set anat_cp       = ${dir_ssw}/anatSS.${isubj}.nii
set anat_skull    = ${dir_ssw}/anatU.${isubj}.nii

set roi_all_2009  = ${dir_suma}/aparc.a2009s+aseg_REN_all.nii.gz
set roi_FSvent    = ${dir_suma}/fs_ap_latvent.nii.gz
set roi_FSWe      = ${dir_suma}/fs_ap_wm.nii.gz

set dsets_NL_warp = ( ${dir_ssw}/anatQQ.${isubj}.nii         \
                      ${dir_ssw}/anatQQ.${isubj}.aff12.1D    \
                      ${dir_ssw}/anatQQ.${isubj}_WARP.nii  )


set dsets_epi     = ( ${dir_epi}/epi.r11.rest_chan_002+orig.HEAD )

set template      = MNI152_2009_template_SSW.nii.gz

# control variables
set nt_rm         = 4
set blur_size     = 5
set final_dxyz    = 3      # can test against inputs
set cen_motion    = 0.2
set cen_outliers  = 0.05

# ---------------------------------------------------------------------------
# run afni_proc.py
# ---------------------------------------------------------------------------
afni_proc.py                                                            \
     -subj_id                  s.${label}                               \
     -blocks despike tshift align tlrc volreg blur mask scale regress   \
     -radial_correlate_blocks  tcat volreg                              \
     -copy_anat                ${anat_cp}                               \
     -anat_has_skull           no                                       \
     -anat_follower            anat_w_skull anat ${anat_skull}          \
     -anat_follower_ROI        aaseg        anat ${roi_all_2009}        \
     -anat_follower_ROI        aeseg        epi  ${roi_all_2009}        \
     -anat_follower_ROI        FSvent       epi  ${roi_FSvent}          \
     -anat_follower_ROI        FSWe         epi  ${roi_FSWe}            \
     -anat_follower_erode      FSvent FSWe                              \
     -dsets                    ${dsets_epi}                             \
     -tcat_remove_first_trs    ${nt_rm}                                 \
     -align_opts_aea           -cost lpc+ZZ -giant_move -check_flip     \
     -tlrc_base                ${template}                              \
     -tlrc_NL_warp                                                      \
     -tlrc_NL_warped_dsets     ${dsets_NL_warp}                         \
     -volreg_align_to          MIN_OUTLIER                              \
     -volreg_align_e2a                                                  \
     -volreg_tlrc_warp                                                  \
     -volreg_warp_dxyz         ${final_dxyz}                            \
     -volreg_compute_tsnr      yes                                      \
     -blur_size                ${blur_size}                             \
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

