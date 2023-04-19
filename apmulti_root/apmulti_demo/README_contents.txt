
    **  please see README_process.txt for running the analysis      **
    **  please post comments or question to the AFNI message board  **

This is a sample set of processing scripts to analyze multi-echo resting
state data in various ways.  The analysis has basic processing steps:

   1. FreeSurfer   : for ROIs and possibly surface mapping
                      - for surface analysis (in one afni_proc.py example)
                      - for ANATICOR
                      - for QC - to create correlation images
   2. @SSwarper    : for skull-stripping an non-linear template registration
   3. RetroTS.py   : convert physiological signals to regressors
                      - for ricor processing (in one afni_proc.py example)
   4. afni_proc.py : single subject analysis
                      - various examples of how one might run an analysis

===========================================================================
The basic input is a BIDS-formatted tree for just a single subject/session:

   data_00_basic
      anat   : anat/sub-005_ses-01_mprage_run-1_T1w.nii.gz
      blip   : func/sub-005_ses-01_acq-blip_dir-match_run-1_bold.nii.gz
      blip   : func/sub-005_ses-01_acq-blip_dir-opp_run-1_bold.nii.gz
      epi    : func/sub-005_ses-01_task-rest_run-1_echo-1_bold.nii.gz
      epi    : func/sub-005_ses-01_task-rest_run-1_echo-2_bold.nii.gz
      epi    : func/sub-005_ses-01_task-rest_run-1_echo-3_bold.nii.gz
      physio : func/sub-005_ses-01_task-rest_run-1_physio-ECG.txt
      physio : func/sub-005_ses-01_task-rest_run-1_physio-Resp.txt

   note: echo times (in ms) are : 12.5 27.6 42.7

---------------------------------------------
The results from steps 1, 2 and 3 (above) will be distributed for convenience.
Scripts to generate these initial results are included.  Feel free to (re)move
these directories are generate them with the included scripts.

   data_12_fs
      - processed from anat
      - FreeSurfer output, imported to AFNI/SUMA
         - SUMA directory, created by @SUMA_Make_Spec_FS

   data_13_ssw
      - processed from anat
      - @SSwarper output

   data_14_physio
      - processed from physiological signals
      - RetroTS.py output

===========================================================================
There are 2 parallel sets of scripts:

   scripts_biowulf   : for running on NIH's high-performance cluster
   scripts_desktop   : for running on a desktop system

One can use scripts from either directory for any step.  For example, it is 
okay to run some of the analysis on biowulf and some on a desktop (with the
apmulti_demo tree copied between them).

   
Within each script directory are:

   run_* scripts  : these are what should be directly run
                  - controls for subjects and biowulf swarming
                  - these end up executing corresponding do_* scripts
           run_1* : produce output for steps 1, 2 and 3 (noted at the top)
           run_2* : different examples of how one might choose to processes
                    their data using afni_proc.py

   do_*  scripts  : called by the run_* scripts with the same naming
                  - actually perform the detailed processing steps
                  - include logging (storing text output in log files)

===========================================================================
do_*/run_* script labels:

   A label will refer to a run_* script, a do_* script, and an output data_*
   directory.  For example label 26_ap_me_bT (for an afni_proc.py example)
   refers to:

      scripts_desktop/do_26_ap_me_bT.tcsh    - AP command for desktop
      scripts_desktop/run_26_ap_me_bT.tcsh   - main script for desktop
      scripts_biowulf/do_26_ap_me_bT.tcsh    - AP command for biowulf
      scripts_biowulf/run_26_ap_me_bT.tcsh   - main script for biowulf
      data_26_ap_me_bT                       - output tree

   Label 26_ap_me_bT implies:

      26     - example 26
      ap     - an afni_proc.py command
      me     - multi-echo processing (as opposed to 'se' for single-echo)
      b      - blip up/down distortion correction
      T      - tedana processing using version from MEICA group

   All label characters:

      fs     - FreeSurfer
      ssw    - @SSwarper
      physio - RetroTS.py processing of physiological time series
      se     - single-echo analysis (echo 2 of 3)
      me     - multi-echo processing (3 echoes)
      b      - blip up/down distortion correction
      n      - no blurring (omit blur processing step)
      r      - include 'ricor' processing block (RetroTS.py)
      s      - surface analysis
      t      - tedana processing using version from Prantik
      T      - tedana processing using version from MEICA group

