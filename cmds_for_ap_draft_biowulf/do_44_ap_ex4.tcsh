#!/usr/bin/env tcsh

# AP: for AP draft, ex 4
# -> now with local epi unifize

# Process a single subj+ses pair.  Run this script in
# apmulti_demo/scripts/, via the corresponding run_*tcsh script.

# This is a Biowulf script.  Run it via swarm (see partner run*.tcsh).

# ----------------------------- biowulf-cmd ---------------------------------

# load modules
source /etc/profile.d/modules.csh
module load afni 

# need external prog 'tedana' too;  perhaps using conda similar to:
### source /data/NIMH_SSCC/ptaylor/miniconda/etc/profile.d/conda.csh
### conda activate env_tedana
### conda env list

echo `which tedana`
if ( $status ) then
    echo "** ERROR: 'tedana' not loaded, installed or found."
    echo "   Did you forget to start a conda env or something?"
    set ecode = 1
    goto COPY_AND_EXIT
endif

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
set ap_label       = 44_ap_ex4

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
set dsets_epi_me  = ( ${sdir_epi}/${subj}_${ses}_task-rest_*_echo-?_bold.nii* )
set me_times      = ( 12.5 27.6 42.7 )

set epi_forward   = "${sdir_epi}/${subj}_${ses}_acq-blip_dir-match_run-1_bold.nii.gz[0]"
set epi_reverse   = "${sdir_epi}/${subj}_${ses}_acq-blip_dir-opp_run-1_bold.nii.gz[0]"

set anat_cp       = ${sdir_ssw}/anatSS.${subj}.nii
set anat_skull    = ${sdir_ssw}/anatU.${subj}.nii

set surf_anat     = ${sdir_suma}/${subj}_SurfVol.nii
set surf_specs    = ( ${sdir_suma}/std.141.${subj}_?h.spec )

set roi_all_2009    = ${sdir_suma}/aparc.a2009s+aseg_REN_all.nii.gz
set roi_FSvent      = ${sdir_suma}/fs_ap_latvent.nii.gz
set roi_FSWe        = ${sdir_suma}/fs_ap_wm.nii.gz


# control variables
set nt_rm         = 4
set blur_size     = 4
###set final_dxyz    = 3      # not for surf
set cen_motion    = 0.2
set cen_outliers  = 0.05

# ----------------------------- biowulf-cmd --------------------------------

# try to use /lscratch for speed 
if ( -d /lscratch/$SLURM_JOBID ) then
    set usetemp  = 1
    set sdir_BW  = ${sdir_ap}
    set sdir_ap  = /lscratch/$SLURM_JOBID/${subj}_${ses}

    # prep for group permission reset
    \mkdir -p ${sdir_BW}
    set grp_own  = `\ls -ld ${sdir_BW} | awk '{print $4}'`
else
    set usetemp  = 0
endif

# ---------------------------------------------------------------------------
# run programs
# ---------------------------------------------------------------------------

set ap_cmd = ${sdir_ap}/ap.cmd.${subj}

\mkdir -p ${sdir_ap}

# write AP command to file
cat <<EOF >! ${ap_cmd}

# blip up/down (B0 distortion) correction applied
# surface-based analysis
# ME combine method: MEICA-group tedana

afni_proc.py                                                            \
     -subj_id                  ${subj}                                  \
     -blocks                   despike tshift align volreg mask combine \
                               surf blur scale regress                  \
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
     -combine_method           m_tedana                                 \
     -tcat_remove_first_trs    ${nt_rm}                                 \
     -tshift_interp            -wsinc9                                  \
     -align_unifize_epi        local                                    \
     -align_opts_aea           -cost lpc+ZZ -giant_move -check_flip     \
     -volreg_align_to          MIN_OUTLIER                              \
     -volreg_align_e2a                                                  \
     -volreg_warp_final_interp  wsinc5                                  \
     -volreg_compute_tsnr      yes                                      \
     -mask_epi_anat            yes                                      \
     -regress_motion_per_run                                            \
     -regress_make_corr_vols   aeseg FSvent                             \
     -regress_censor_motion    ${cen_motion}                            \
     -regress_censor_outliers  ${cen_outliers}                          \
     -regress_apply_mot_types  demean deriv                             \
     -html_review_style        pythonic                                                                                                       

EOF

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

cd ${sdir_ap}

# execute AP command to make processing script
tcsh -xef ${ap_cmd} |& tee output.ap.cmd.${subj}

if ( ${status} ) then
    set ecode = 1
    goto COPY_AND_EXIT
endif

# execute the proc script, saving text info
time tcsh -xef proc.${subj} |& tee output.proc.${subj}

if ( ${status} ) then
    echo "++ FAILED AP: ${ap_label}"
    set ecode = 1
    goto COPY_AND_EXIT
else
    echo "++ FINISHED AP: ${ap_label}"
endif

# ---------------------------------------------------------------------------

COPY_AND_EXIT:

# ----------------------------- biowulf-cmd --------------------------------

# copy back from /lscratch to "real" location
if( ${usetemp} && -d ${sdir_ap} ) then
    echo "++ Used /lscratch"
    echo "++ Copy from: ${sdir_ap}"
    echo "          to: ${sdir_BW}"
    \cp -pr   ${sdir_ap}/* ${sdir_BW}/.

    # reset group permission and writeability
    chgrp -R ${grp_own} ${sdir_BW}
    chmod -R g+w ${sdir_BW}
endif

# ---------------------------------------------------------------------------

exit ${ecode}
