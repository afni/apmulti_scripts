This is the first 12 volumes from echo 2.
Volume 0 is stored as 000 to allow separation in globbing.

# ----------------------------------------------------------------------
   # made from:
   set subj = AP.12
   mkdir -p ../nifti_12_vols.e2
   3dTsplit4D -keep_datum -prefix ../nifti_12_vols.e2/e2.nii   \
             $subj.results/pb00.$subj.r01.e02.tcat+orig

   # separate time index 0 from others, for optional globbing
   cd ../nifti_12_vols.e2
   foreach file ( e2.* )
      set ind = $file:r:e
      if ( $ind == 00 ) then
         mv $file e2.0$ind.nii
      else
         mv $file e2.1$ind.nii
      endif
   end
# ----------------------------------------------------------------------
