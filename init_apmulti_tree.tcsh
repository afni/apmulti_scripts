#!/usr/bin/env tcsh

# ---------------------------------------------------------------------------
# build APMULTI tree *in place*
# input: require path to apmulti_data.tgz file
# output: the resulting tree will be put here ($PWD)

# example usage:
# tcsh ../APMULTI_FULL/init_apmulti_tree.tcsh \
#      ../APMULTI_FULL/apmulti_data.tgz |& tee out.init_tree.txt
# ---------------------------------------------------------------------------

set datadir     = apmulti_data
set reponame    = apmulti_scripts

# for biowulf: Only lscratch is now available, and only from the current
#              compute node or batched set of nodes.  So jobs must be either
#              So unless this script is changed for swarming, no reference
#              will be made to a scratch dir.

if ( -d $datadir ) then
   echo "** there is already a $datadir here"
   echo "   please run from a clean directory"
   exit 1
endif

# ---------------------------------------------------------------------------
# require input to be a path to apmulti_data.tgz and work from there

set tgzpath = $1

# and note the directory and name
set tgzfile = $tgzpath:t
set tgzdir  = $tgzpath:h
if ( $tgzdir == $tgzpath ) then
   set tgzdir = .
endif

if ( $tgzfile != $datadir.tgz ) then
   echo "** input should be path/to/$datadir.tgz"
   exit 0
endif

# require sight of the .tgz file
if ( ! -f $tgzdir/$datadir.tgz ) then
   echo "** do not see $tgzdir/$datadir.tgz"
   echo "         from $tgzpath"
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
endif

echo ""
echo "-- ready to work from $PWD, input is $datadir.tgz :"
ls -lh $tgzdir/$datadir.tgz
echo ""
echo "++ starting by cloning git repo"
echo ""

set echo

# clone repo
git clone https://github.com/afni/$reponame.git
if ( $status ) then
   exit 1
endif

# unpack tree
time tar xfz $tgzdir/$datadir.tgz

echo ""
echo "...done"
echo ""
