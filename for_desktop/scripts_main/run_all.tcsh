
# possibly init tree from apmulti_data.tgz using init_apmulti_tree.tcsh
# (nothing else is required for entire setup and analysis)
tcsh -x ../git/apmulti_scripts/init_apmulti_tree.tcsh apmulti_data.tgz \
        |& tee out.init_tree.txt

# now get the script repo and initialize the sub-trees
# (using the desktop version gets all desktop scripts)
tcsh -xef apmulti_scripts/for_desktop/scripts_main/do_00_init_tree.tcsh \
        |& tee log_00_init.txt
\mv log_00_init.txt apmulti_root/logs

# create NIFTI datasets (run Dimon and rename/convert to NIFTI)
cd apmulti_root/apmulti_dicom
tcsh -xef scripts/do_11_run_dimon.tcsh |& tee logs/log_11.run_dimon.txt

tcsh -xef scripts/do_12_copy_epi.tcsh | & tee logs/log_12.copy_epi.txt

# copy NIFTI EPI from dicom tree to demo tree
#
# from apmulti_root, copy EPI from apmulti_dicom to apmulti_demo
# for now, just copy the rest??
cd ..
tcsh -ef scripts/do_01_dicom2demo.tcsh |& tee log_01_dicom2demo.txt
\mv log_01_dicom2demo.txt logs
