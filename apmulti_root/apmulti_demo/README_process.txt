This package comes with some processing already having been run:

   - FreeSurfer (run_12_fs.tcsh)
   - @SSwarper  (run_13_ssw.tcsh)
   - RetroTS.py (run_14_physio.tcsh)

The scripts that one should consider running are named run_*.  Minimally,
all that remains if for one to run even a single afni_proc.py script,
such as scripts_desktop/run_26_ap_me_bT.tcsh.  For example, it would be
suffient to simply run:

   cd scripts_desktop
   tcsh run_26_ap_me_bT.tcsh

On biowulf, one can run the similar scripts from the scripts_biowulf
directory, which include things like swarming and lscratch directory use.

----------------------------------------------------------------------
The description of the script file naming is in README.txt.

Any of the run_LABEL.tcsh scripts can be run (on biowulf or a desktop)
to perform the given LABEL step.  The result would be a data_LABEL
directory (where LABEL would be 26_ap_me_bT in the above example).

Here is the list of run_* scripts (under scripts_biowulf or scripts_desktop),
with any comments for extra software considerations (besides AFNI).

   * Prantik's tedana comes with AFNI
   * MEICA tedana must be installed separately, with 'tedana' in the PATH
     - see https://tedana.readthedocs.io/en/stable/installation.html
   * FreeSurfer must be installed separately
     - see https://surfer.nmr.mgh.harvard.edu


   processing script            processing requirements (besides AFNI)
   -----------------            --------------------------------------
   run_12_fs.tcsh               requires FreeSurfer
   run_13_ssw.tcsh
   run_14_physio.tcsh
   run_20_ap_se.tcsh
   run_21_ap_me.tcsh
   run_22_ap_me_b.tcsh
   run_23_ap_me_bt.tcsh         Prantik's tedana.py requires python 2.7
   run_24_ap_me_bts.tcsh        Prantik's tedana.py requires python 2.7
   run_25_ap_me_br.tcsh
   run_26_ap_me_bT.tcsh         MEICA tedana requires 'tedana' and python 3.6+
   run_30_ap_se_n.tcsh
   run_33_ap_me_btn.tcsh        Prantik's tedana.py requires python 2.7
   run_36_ap_me_bTn.tcsh        MEICA tedana requires 'tedana' and python 3.6+

