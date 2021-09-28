#!/usr/bin/env tcsh

# ---------------------------------------------------------------------------
# basic, single echo rest, but more like example 13
# ---------------------------------------------------------------------------

# Note: The tedana.py called by this script for combine_method = 'OC_tedort'
#       requires using Python 2.7.

# ---------------------------------------------------------------------------
# data and control variables
# ---------------------------------------------------------------------------

# labels
set label         = 4.ex13.surf
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

set surf_anat     = ${dir_suma}/sub_001_SurfVol.nii
set surf_specs    = ( ${dir_suma}/std.141.sub_001_?h.spec )

set epi_forward   = "${dir_epi}/epi.r04.blip.fwd.chan2+orig[0]"
set epi_reverse   = "${dir_epi}/epi.r03.blip+orig[0]"
set dsets_epi_me  = ( ${dir_epi}/epi.r11.rest_chan_*+orig.HEAD )
set me_times      = ( 12.5 27.6 42.7 )


# control variables
set nt_rm         = 4
set blur_size     = 8
set cen_motion    = 0.2
set cen_outliers  = 0.05

# ME:
#   - -dsets_me_run, -echo_times -combine_method
#   - mask combine blur

# ---------------------------------------------------------------------------
# run afni_proc.py
# ---------------------------------------------------------------------------
afni_proc.py                                                            \
     -subj_id                  s.${label}                               \
     -blocks despike tshift align volreg mask combine surf blur scale   \
         regress                                                        \
     -radial_correlate_blocks  tcat volreg                              \
     -copy_anat                ${anat_cp}                               \
     -anat_has_skull           no                                       \
     -anat_follower            anat_w_skull anat ${anat_skull}          \
     -anat_follower_ROI        aaseg        anat ${roi_all_2009}        \
     -anat_follower_ROI        aeseg        epi  ${roi_all_2009}        \
     -anat_follower_ROI        FSvent       epi  ${roi_FSvent}          \
     -anat_follower_ROI        FSWe         epi  ${roi_FSWe}            \
     -anat_follower_erode      FSvent FSWe                              \
     -surf_anat                ${surf_anat}                             \
     -surf_spec                ${surf_specs}                            \
     -blip_forward_dset        "${epi_forward}"                         \
     -blip_reverse_dset        "${epi_reverse}"                         \
     -dsets_me_run             ${dsets_epi_me}                          \
     -echo_times               ${me_times}                              \
     -combine_method           OC_tedort                                \
     -combine_tedort_reject_midk  no                                    \
     -tcat_remove_first_trs    ${nt_rm}                                 \
     -tshift_interp            -wsinc9                                  \
     -align_opts_aea           -cost lpc+ZZ -giant_move -check_flip     \
     -volreg_align_to          MIN_OUTLIER                              \
     -volreg_align_e2a                                                  \
     -volreg_warp_final_interp  wsinc5                                  \
     -volreg_compute_tsnr      yes                                      \
     -blur_size                ${blur_size}                             \
     -mask_epi_anat            yes                                      \
     -regress_motion_per_run                                            \
     -regress_make_corr_vols   aeseg FSvent                             \
     -regress_censor_motion    ${cen_motion}                            \
     -regress_censor_outliers  ${cen_outliers}                          \
     -regress_apply_mot_types  demean deriv                             \
     -html_review_style        pythonic  

   # -compare_opts 'example 13'

