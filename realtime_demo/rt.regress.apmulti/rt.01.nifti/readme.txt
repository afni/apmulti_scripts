
---------------------------------------------------------------------------
Regression testing of the realtime system with single echo data.

This demonstrates AFNI's realtime system sending only motion parameters,
   AFNI_REALTIME_Mask_Vals = Motion_Only

Compare RT results with others or non-RT ones.
   1. with 00.basic: are mot params the same
   2. with 00.basic: are reg dsets equal (can diff by +/- 1)
---------------------------------------------------------------------------

# To test, either run the 3 main scripts in one terminal each:
#     run.0.receiver
#     run.1.afni
#     run.2.dimon
#
# or run the 'all' script to just run and close the programs:
#     run.8.all
#
#
# To remove the old results, run the cleanup script,:
#     run.9.cleanup
