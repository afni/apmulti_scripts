#!/usr/bin/env tcsh

# possibly init tree from apmulti_data.tgz using init_apmulti_tree.tcsh
# (nothing else is required for entire setup and analysis)
tcsh -x ../git/apmulti_scripts/init_apmulti_tree.tcsh \
        ../apmulti_subj_packages/sub-004.tgz          \
        |& tee out.init_tree.txt

# now get the script repo and initialize the sub-trees
# (using the desktop version gets all desktop scripts)
tcsh -xef apmulti_scripts/apmulti_root/scripts_desktop/do_00_init_tree.tcsh \
        |& tee log_00_init.txt
\mv log_00_init.txt apmulti_root/logs

# create NIFTI datasets (run Dimon and rename/convert to NIFTI)
cd apmulti_root/apmulti_dicom
tcsh -xef scripts_desktop/do_11_run_dimon.tcsh \
          |& tee logs/log_11.run_dimon.txt

tcsh -xef scripts_desktop/do_12_copy_epi.tcsh \
          | & tee ../logs/log_12.copy_epi.txt

# copy NIFTI EPI from dicom tree to demo tree
#
# from apmulti_root, copy EPI from apmulti_dicom to apmulti_demo
# for now, just copy the rest??
cd ..
tcsh -ef scripts_desktop/do_01_dicom2demo.tcsh |& tee log_01_dicom2demo.txt
\mv log_01_dicom2demo.txt logs


# ---------------------------------------------------------------------------
# extract release demo
#
# a. update git repo (not in demo tree)
# b. make demo tree (exclude temp tgz's and AP result trees):
#    rsync -av --exclude \*.tgz --exclude \*.results apmulti_demo demo.release
#    cd demo.release/apmulti_demo
# c. delete all AP results
#    rm -fr data_2*
#    rm logs/???_2*
#    rm swarms/swarm_2*
# d. redo script dirs
#    rm -fr scripts_*
#    rsync -av $gitdir/apmulti_root/apmulti_demo/ .
# e. and rename????  (apmulti_demo -> apmulti_demo_01_baic?)
#    (since there may be other aspects to use in future demos?)
#    cd ..
#    mv apmulti_demo apmulti_demo_01_basic
#
# The resulting tree is now 1.5G, apmulti_demo.tgz is size 814M.
# 
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# and re-analyze demo data, to verify
#
# we could almost run:
# ----------------------------------------
# cd apmulti_demo_01_basic/scripts_biowulf
# 
# foreach run ( run_[23]* )
#    tcsh $run
# end
# ----------------------------------------
#
# but the 'T' require python3, while python2 works for the rest

