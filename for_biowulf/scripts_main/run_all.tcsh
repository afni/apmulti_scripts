
tcsh -xef apmulti_scripts/for_biowulf/scripts_main/do_00_init_tree.tcsh \
        |& tee log_00_init.txt
\mv log_00_init.txt apmulti_root/logs

cd apmulti_root/apmulti_dicom
tcsh -xef scripts/do_11_run_dimon.tcsh |& tee logs/log_11.run_dimon.txt

tcsh -xef scripts/do_12_copy_epi.tcsh | & tee logs/log_12.copy_epi.txt



