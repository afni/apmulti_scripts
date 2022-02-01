
---------------------------------------------------------------------------
Regression testing of the realtime system with single echo data.

This demonstrates AFNI's realtime system sending only motion parameters,
   AFNI_REALTIME_Mask_Vals = Motion_Only

Dimon reads DICOM files, collects them into volumes, sends them to afni,
which aligns them (in real time).  The six motion parameters are send to
and displayed by realtime_receiver.py.

The basic test verifies that 6 columns of motion parameters are output.
---------------------------------------------------------------------------

# To test, either run the 3 main scripts in one terminal each:
#     run.0.reciever
#     run.1.afni
#     run.2.dimon
#
# or run the 'all' script to just run and close the programs:
#     run.8.all
#
#
# To remove the old results, run the cleanup script,:
#     run.9.cleanup
