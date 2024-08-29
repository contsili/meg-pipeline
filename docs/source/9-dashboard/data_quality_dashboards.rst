Data Quality Dashboards
#######################

An MEG signal is a tiny magnetic fields, in the order of 100 fT, where
femtotesla  :math:`1fT = 10^{-15} T` and picotesla :math:`1pT = 10^{-12} T`.

EEG scalp signals are about 50 to 100 :math:`\mu\text{V}`


Several metrics are defined in the below table and will serve as basis to asess the quality of data.

.. include:: noise_metrics.rst

.. include:: con_files_statistics.rst

.. include:: KIT_data_quality_dashboard.rst

.. include:: OPM_data_quality_dashboard.rst

Plot of Average and Variance Over Time
######################################

.. raw:: html

    <iframe src="../_static/average_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/variance_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/average_plot_opm_data.html" width="100%" height="600px"></iframe>

Dashboard generation developper guide
#####################################

The dashboard is generated from empty room data hosted on NYU-BOX storage drive.
The scripts generating the dashboard are under `docs/source/9-dashboard/dashboard-generating-scripts`

- `box_script.py` connects to NYU BOX and downloads empty room data to the build server
- `processing_con_files_for_table.py` process the .con files, compute the metrics and generates a .csv file with the results
- `convert_csv_to_rst.py` generates rst pages from the csv files

Documentation for the following dashboard
##########################################

The following dashboard contains: one table containing the status of each empty-room data file, and two graphs containing the average and the variance of each empty-room data file.
1.Data source:
Box-data download .con files , date from the metadata of each file, we get the date of last-modified
2. Over-view of the table:
create table
column-name/description/matrics
3.Use cases
monitor status using table: green means everything is well, red means somthing is wrong
get the average of each room data with variance.
