#!/bin/tcsh

set outdir = dimon.output
cd $outdir

3dTcat -prefix epi.r04.blip.fwd.chan2 epi.r04.naming_1.1_chan_002+orig'[0..9]'
