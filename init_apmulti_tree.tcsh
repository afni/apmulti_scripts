#!/usr/bin/env tcsh

# ---------------------------------------------------------------------------
# build APMULTI tree *in place*
# input: list of of subject data packages
# output: the resulting tree will be put here ($PWD)

# example usage:
# tcsh init_apmulti_tree.tcsh \
#      apmulti_subj_packages/sub-004.tgz |& tee out.init_tree.txt
# ---------------------------------------------------------------------------

set datadir     = apmulti_data
set reponame    = apmulti_scripts

# for biowulf: Only lscratch is now available, and only from the current
#              compute node or batched set of nodes.  So jobs must be either
#              So unless this script is changed for swarming, no reference
#              will be made to a scratch dir.

# ---------------------------------------------------------------------------
# require input to be a path to sub-*.tgz and work from there

set prog = `basename $0`
if ( $#argv != 1 ) then
   echo "usage: $prog path/to/sub-XXX.tgz"
   exit 0
endif

set tgzpath = $1

# note the directory and name of tgz file, and check the format
set tgzfile = $tgzpath:t
set tgzdir  = $tgzpath:h
if ( $tgzdir == $tgzpath ) then
   set tgzdir = .
endif
# update tgzdir to be a full path
cd $tgzdir
set tgzdir = `pwd`
cd -

# note subject and extension
set subj = $tgzfile:r
set ext = $tgzfile:e

# and test them
echo "++ tgz input subj = $subj, ext = $ext"
if ( ! ($subj =~ sub-???) || ($ext != tgz) ) then
   echo "** invalid input format"
   exit 1
endif

# require sight of the .tgz file
if ( ! -f $tgzdir/$tgzfile ) then
   echo "** do not see path $tgzdir/$tgzfile"
   exit 1
endif

# finally, make sure we do not alreayd have this subject
if ( -d $datadir/$subj ) then
   echo "** already have $datadir/$subj, will not overwrite"
   exit 1
endif

# we no longer need a path to the .tgz file
# (since /scratch is not used)

# ---------------------------------------------------------------------------
# start with .tgz so that we do not need to read thousands of files each time
# O . M . G .  even creating the tgz file is soooooooo slow
# but it's only 1.4 GB for a 21 GB tree?!?
# ---------------------------------------------------------------------------

# unpack tgz and download git repo

# clone repo
echo git clone https://github.com/afni/$reponame.git
git clone https://github.com/afni/$reponame.git
if ( $status ) then
   exit 1
endif
echo ""

if ( ! -d $datadir ) then
   mkdir $datadir
   if ( $status ) then
      echo "** no permission to write here"
      exit 1
   endif
endif
cd $datadir

echo ""
echo "-- ready to work from $PWD, input is $tgzfile :"
ls -lh $tgzdir/$tgzfile
echo ""
echo "++ starting by cloning git repo"
echo ""

# unpack tree
echo time tar xfz $tgzdir/$tgzfile
time tar xfz $tgzdir/$tgzfile

echo ""
echo "...done"
echo ""
