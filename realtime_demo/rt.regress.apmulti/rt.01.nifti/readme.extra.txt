
Extra tests can be run with various lengths by modifying nifti_12_vols.e2
and/or cmd.dimon, to add or subtract initial TR.
This allows us to verify that there is no change in remaining vols
(i.e. alignment is consistent, regardless of time index).

This test is the main reason all basic scripts use an external registration
base.


After running cmd.dimon as it is (-infile_pat 'e2.*.nii'):
   a. add an extra volume:
          cd ../nifti_12_vols.e2
          cp e2.000.nii e2.001.nii
      and re-run afni/dimon
      (and can rm e2.001.nii)

   b. remove the initial volume
      can do it in Dimon via (-infile_pat 'e2.1*.nii'):
         - or mv e2.000.nii save.e2.000.nii and move back

   c. do some length comparisons:

      cd afni.rt
      set d12 = rt.__001%reg3D+orig
      set d13 = rt.__002%reg3D+orig
      set d11 = rt.__003%reg3D+orig

      # first 2 vols of d13 should be identical
      3dcalc -a $d13'[0]' -b $d13'[1]' -expr a-b -prefix d0.nii
      3dBrickStat -slow -max d0.nii
         OR (using .HEAD to separate var from [])
      3dBrickStat -slow -absolute -max \
         "3dcalc -a $d13.HEAD[0] -b $d13.HEAD[1] -expr a-b"

      # $d12 should match last 12 vols of $d13
      3dBrickStat -slow -absolute -max \
         "3dcalc -a $d13.HEAD[1..12] -b $d12 -expr a-b"

      # finally, $d11 should match last 11 vols of $d13 (unneeded?)
      3dBrickStat -slow -absolute -max \
         "3dcalc -a $d13.HEAD[2..12] -b $d11 -expr a-b"

   d. more volreg comparisons
      3dvolreg -base ../../RT_input/RT_extras/vr_base+orig \
               -quintic -prefix vr.e2.13 rt.__002+orig
      3dvolreg -base ../../RT_input/RT_extras/vr_base+orig \
               -quintic -prefix vr.e2.11 rt.__003+orig

      set regrt = $d13
      set regvr = vr.e2.13+orig
      3dBrickStat -slow -absolute -max \
         "3dcalc -a $regrt -b $regvr -expr a-b"

      set regrt = $d11
      set regvr = vr.e2.11+orig
      3dBrickStat -slow -absolute -max \
         "3dcalc -a $regrt -b $regvr -expr a-b"


      --> There is a difference in volreg of base 0, probably because of
          the pre-ss contrast difference.

