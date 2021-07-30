# ---------------------------------------------------------------------------
# build APMULTI tree *in place*
# input: require path to apmulti_data.tgz file
# assumes: biowulf execution

# example usage:
# tcsh ../APMULTI_FULL/init_apmulti_tree.tcsh \
#      ../APMULTI_FULL/apmulti_data.tgz |& tee out.init_tree.txt
# ---------------------------------------------------------------------------

set datadir     = apmulti_data
set reponame    = apmulti_scripts

# on biowulf, this works better from the /scratch tree
# set to 0 to put the data into the current location
set use_scratch = 1
set dir_scratch = /scratch/$user

# check to see whether the scratch dir exists
if ( $use_scratch && ! -d $dir_scratch ) then
   echo "** missing scratch dir, $dir_scratch"
   echo "   (consider clearing use_scratch in script)"
   exit 0
endif

# put the results here or under $dir_scratch
# (if $use_scratch, they will be left there with a suggestion to sync back)
set destdir = `pwd`

if ( $use_scratch ) then
   set testdir = $dir_scratch
else
   set testdir = $datadir
endif

if ( -d $testdir/$datadir ) then
   echo "** there is already a $datadir under $testdir"
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

# finally, get a full path to the file
cd $tgzdir
set tgzdir = `pwd`
cd -

# ---------------------------------------------------------------------------
# start with .tgz so that we do not need to read thousands of files each time
# O . M . G .  even creating the tgz file is soooooooo slow
# but it's only 1.4 GB for a 21 GB tree?!?
# ---------------------------------------------------------------------------

# if use_scratch, go there
# either way, unpack tgz and download git repo
if ( $use_scratch ) then

   # go to the alternate scratch location
   cd $dir_scratch
endif

echo ""
echo "-- ready to work from $PWD, input is:"
ls -lh $tgzdir/$datadir.tgz
echo ""
echo "++ starting by cloning git repo, needs password..."
echo ""

set echo

# clone repo
git clone https://github.com/afni/$reponame.git
if ( $status ) then
   exit 1
endif

# unpack tree
time tar xfz $tgzdir/$datadir.tgz

unset echo
echo ""
echo "consider:"
echo ""
echo "   cd $PWD"
echo "   time tcsh apmulti_scripts/scripts_main/run_all.tcsh"
echo "   rsync -av . $destdir/"
echo ""
echo "   cd $destdir"
echo "   chown -R :APMULTI ."
echo "   chmod -R g+w ."
echo "   find . -type d -exec chmod g+s {} \;"
echo ""

