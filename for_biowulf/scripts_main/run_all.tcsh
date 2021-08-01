
# running the for_biowulf version gets all biowulf scripts
tcsh -xef apmulti_scripts/for_biowulf/scripts_main/do_00_init_tree.tcsh \
        |& tee log_00_init.txt
\mv log_00_init.txt apmulti_root/logs

# create NIFTI datasets
cd apmulti_root/apmulti_dicom
tcsh -xef scripts/do_11_run_dimon.tcsh |& tee logs/log_11.run_dimon.txt

tcsh -xef scripts/do_12_copy_epi.tcsh | & tee logs/log_12.copy_epi.txt

# from apmulti_root, copy EPI from apmulti_dicom to apmulti_demo
# for now, do we just copy the rest?
cd ..
tcsh -ef scripts/do_01_dicom2demo.tcsh |& tee log_01_dicom2demo.txt
\mv log_01_dicom2demo.txt logs
