
              Welcome to APMULTI demo 02 - realtime
                (AFNI realtime system processing)

This package demonstrates much of the common functionality of AFNI's real-time
system.  The input is a collection of 12 volumes, initially stored as:

   DICOM with a single echo
   DICOM with 3 echoes
   NIFTI with a single echo


To run the complete set of scripts, it is enough to:

   tcsh run.regress

This relies on cmd.regress, which might backup the regression comparison files
(some of the log/* text files).  It can also be run to clean the old results
(see clean_rt in cmd.regress).  This full script takes about 75 seconds to run
(presently), mostly due to 'sleep' statements between script pieces.



To run a single realtime process (e.g. with rt.00.basic), one can:

   cd rt.00.basic
   tcsh run.8.all

This will run all scripts in that directory.

Alternatively, one might want to run and monitor the scripts.  In this case,
one would usually run a single script per terminal window (using 3 or 4 
terminal windows, depending), as in:

   cd rt.00.basic
   tcsh run.0.receiver
   tcsh run.1.afni
   tcsh run.2.dimon
   tcsh run.3.stats

There is also a run.9.cleanup script in each directory.

--------------------
R Reynolds  Feb 2022

