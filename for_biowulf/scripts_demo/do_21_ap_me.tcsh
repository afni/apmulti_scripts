#!/usr/bin/env tcsh

# AP: basic, multiecho rest, but more like example 13

# Process a single subj+ses pair.  Run this script in
# apmulti_demo/scripts/, via the corresponding run_*tcsh script.

# This is a Biowulf script.  Run it via swarm (see partner run*.tcsh).

# ----------------------------- biowulf-cmd ---------------------------------

# load modules
source /etc/profile.d/modules.csh
module load afni 

# set N_threads for OpenMP
# + consider using up to 16 threads (alignment programs are parallelized)
setenv OMP_NUM_THREADS $SLURM_CPUS_PER_TASK

# initial exit code; we don't exit at fail, to copy partial results back
set ecode = 0

# --------------------------------------------------------------------------
# top level definitions (constant across demo)
# ---------------------------------------------------------------------------

# labels
set subj           = $1
set ses            = $2

set template       = MNI152_2009_template_SSW.nii.gz 

# upper directories
set dir_inroot     = ${PWD:h}                        # one dir above scripts/
set dir_log        = ${dir_inroot}/logs
set dir_basic      = ${dir_inroot}/data_00_basic
set dir_fs         = ${dir_inroot}/data_12_fs
set dir_ssw        = ${dir_inroot}/data_13_ssw
set dir_physio     = ${dir_inroot}/data_14_physio

set dir_ap_se      = ${dir_inroot}/data_20_ap_se
set dir_ap_me      = ${dir_inroot}/data_21_ap_me
set dir_ap_me_b    = ${dir_inroot}/data_22_ap_me_b
set dir_ap_me_bt   = ${dir_inroot}/data_23_ap_me_bt
set dir_ap_me_bts  = ${dir_inroot}/data_24_ap_me_bts

# subject directories
set sdir_basic     = ${dir_basic}/${subj}/${ses}
set sdir_epi       = ${sdir_basic}/func
set sdir_fs        = ${dir_fs}/${subj}/${ses}
set sdir_suma      = ${sdir_fs}/SUMA
set sdir_ssw       = ${dir_ssw}/${subj}/${ses}
set sdir_physio    = ${dir_physio}/${subj}/${ses}

set sdir_ap_se     = ${dir_ap_se}/${subj}/${ses}
set sdir_ap_me     = ${dir_ap_me}/${subj}/${ses}
set sdir_ap_me_b   = ${dir_ap_me_b}/${subj}/${ses}
set sdir_ap_me_bt  = ${dir_ap_me_bt}/${subj}/${ses}
set sdir_ap_me_bts = ${dir_ap_me_bts}/${subj}/${ses}

# --------------------------------------------------------------------------
# data and control variables
# --------------------------------------------------------------------------

setenv AFNI_COMPRESSOR GZIP

# dataset inputs
set sdir_this_ap  = ${sdir_ap_me}                    # pick AP dir (and cmd)

set dsets_epi_me  = ( ${sdir_epi}/${subj}_${ses}_task-rest_*_echo-?_bold.nii* )
set me_times      = ( 12.5 27.6 42.7 )

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

# ----------------------------- biowulf-cmd --------------------------------

# try to use /lscratch for speed 
if ( -d /lscratch/$SLURM_JOBID ) then
    set usetemp  = 1
    set sdir_BW  = ${sdir_this_ap}
    set sdir_this_ap  = /lscratch/$SLURM_JOBID/${subj}_${ses}
else
    set usetemp  = 0
endif

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

set ap_cmd = ${sdir_this_ap}/ap.cmd.${subj}

\mkdir -p ${sdir_this_ap}

# write AP command to file
cat <<EOF >! ${ap_cmd}

# ME:
#   - -dsets_me_run, -echo_times -combine_method
#   - mask combine blur

afni_proc.py                                                            \
     -subj_id                  ${subj}                                  \
     -blocks despike tshift align tlrc volreg mask combine blur scale   \
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
     -dsets_me_run             ${dsets_epi_me}                          \
     -echo_times               ${me_times}                              \
     -combine_method           OC                                       \
     -tcat_remove_first_trs    ${nt_rm}                                 \
     -tshift_interp            -wsinc9                                  \
     -align_opts_aea           -cost lpc+ZZ -giant_move -check_flip     \
     -tlrc_base                ${template}                              \
     -tlrc_NL_warp                                                      \
     -tlrc_NL_warped_dsets     ${dsets_NL_warp}                         \
     -volreg_align_to          MIN_OUTLIER                              \
     -volreg_align_e2a                                                  \
     -volreg_tlrc_warp                                                  \
     -volreg_warp_final_interp  wsinc5                                  \
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

   # -compare_opts 'example 13'

EOF

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

cd ${sdir_this_ap}

# execute AP command to make processing script
tcsh -xef ${ap_cmd} |& tee output.ap.cmd.${subj}

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

# execute the proc script, saving text info
time tcsh -xef proc.${subj} |& tee output.proc.${subj}

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

echo "++ FINISHED AP"

# ---------------------------------------------------------------------------

COPY_AND_EXIT:

# ----------------------------- biowulf-cmd --------------------------------

# copy back from /lscratch to "real" location
if( ${usetemp} && -d ${sdir_this_ap} ) then
    echo "++ Used /lscratch"
    echo "++ Copy from: ${sdir_this_ap}"
    echo "          to: ${sdir_BW}"
    \mkdir -p ${sdir_BW}
    \cp -pr   ${sdir_this_ap}/* ${sdir_BW}/.
endif

# ---------------------------------------------------------------------------

exit $ecode
