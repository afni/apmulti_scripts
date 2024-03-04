
---------------------------------------------------------------------------
Regression testing of the realtime system with single echo data.

This demonstrates the realtime system using
   AFNI_REALTIME_Mask_Vals ROIs_and_data
with a 5 ROI mask.

Dimon reads DICOM files, collects them into volumes, sends them to afni,
which aligns them (in real time).  ROI means are computed at each time
point in plug_realtime, which sends the motion parameters, 4 ROI means
(of the non-1 ROIs: 2,3,4,5), and all values from ROI 1
to realtime_receiver.py, which just displays them at each time point.

The basic test verifies that maskdump produces the same ROI-1 values
that realtime_receiver.py reports.  It *could* be extended to check the
ROI averages, too.
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

