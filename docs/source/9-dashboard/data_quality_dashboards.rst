Data Quality Dashboards
#######################

An MEG signal is a tiny magnetic fields, in the order of 100 fT, where
femtotesla  :math:`1fT = 10^{-15} T` and picotesla :math:`1pT = 10^{-12} T`.

EEG scalp signals are about 50 to 100 :math:`\mu\text{V}`


Several metrics are defined in the below table and will serve as basis to asess the quality of data.

.. include:: noise_metrics.rst

.. include:: con_files_statistics.rst

.. include:: KIT_data_quality_dashboard.rst

Plot of Average and Variance Over Time
######################################

.. raw:: html

    <iframe src="../_static/average_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/variance_plot.html" width="100%" height="600px" frameborder="0"></iframe>

.. include:: OPM_data_quality_dashboard.rst

Documentation for the following dashboard
##########################################

This dashboard's objective is to monitor the quality of the empty-room data with informative labels, for quick acess and over all numerical values in a simple format.
It has graphs showing the average and variance of each empty-room data file, as well as one table listing the current state of each empty-room data file.

1. The source of this data is the files generated from each experiment, hosted on the NYU-BOX data drive. This process is done by a python script that authontificats on BOX-DATA, downloads all the '.con' files that exists inside the empty-room while also getting the date they were last modified. 

2. Overview of the table:
  *- Column name
   - Description
   - Obteined
   *- Status
   - Gives the status of the given file's average if it's above or in the threshold. Then given status is indicated by a color: green for safe, red for above the threashhold. The threashold is defined at below 3ft.
   - calculates the average of the signal over time and compares it to the threshold decided.
   *  - File Name
   - It is a combonation of time and the name of the file seperated by '-'.
   - Obteined from the metadata available at the NYU-DATA box.
   *  - Average
   - Calculates the average of the signal over time.
   - Calculated by the simple functions defining the average function in python
   *  - Variance
   - Calculates the variance of the signal over time.
   - Calculated by the simple functions defining the variance function in python
   * - Date
   - The date is defined as : "day/month/year min:secs:hours"
   - Obteined by the metadata of the 'last-modified'field.
   * - Details
   - Describes the details of the day and or experiement that might explain the results obteined in the file.
   - Added by user default is "Nothing added yet".

3. Use cases:

   - Easly monitor the status using table
   - Get the average of each room data with variance.

Dashboard generation developper guide
#####################################

The dashboard is generated from empty room data hosted on NYU-BOX storage drive.
The scripts generating the dashboard are under `docs/source/9-dashboard/dashboard-generating-scripts`

- `box_script.py` connects to NYU BOX and downloads empty room data to the build server
- `processing_con_files_for_table.py` process the .con files, compute the metrics and generates a .csv file with the results
- `convert_csv_to_rst.py` generates rst pages from the csv files

