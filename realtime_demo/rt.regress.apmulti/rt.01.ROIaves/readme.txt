
---------------------------------------------------------------------------
Regression testing of the realtime system with single echo data.

This demonstrates AFNI's realtime system using
   AFNI_REALTIME_Mask_Vals ROI_means
with a 5 ROI mask.
.
Dimon reads DICOM files, collects them into volumes, sends them to afni,
which aligns them (in real time).  ROI means are computed at each time
point in plug_realtime, which sends the motion parameters and 5 ROI means
to realtime_receiver.py, which just displays them at each time point.

The basic test verifies that 3dROIstats produces the same means (from
the saved registered time series) as realtime_receiver.py reports.
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
