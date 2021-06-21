
tcsh -x apmulti_scripts/scripts_main/do_00_init_tree.tcsh \
        |& tee log_00_init.txt
\mv log_00_init.txt apmulti_root/logs

cd apmulti_root/apmulti_dicom
tcsh -x scripts/do_01_run_dimon.tcsh |& tee logs/log_01.run_dimon.txt

tcsh -xef scripts/do_02_copy_epi.tcsh | & tee logs/log_02.copy_epi.txt


