Data Quality Dashboards
#######################

An MEG signal is a measurement of a very small magnetic field, in the order of 100 fT, where
femtotesla  :math:`1fT = 10^{-15} T` and picotesla :math:`1pT = 10^{-12} T`.

EEG scalp signals are about 50 to 100 :math:`\mu\text{V}`

Data Quality metrics
====================

The metrics, defined in the table below, will serve as basis to asess the quality of empty-room data acquired from either MEG-KIT or MEG-OPM systems.
The SNR (Signal to Noise Ratio) is a measure that can be qualitatively evaluated given the measurements of the different  metrics.
Poor SNR, can have multiple reasons: new unindentified recurrent noise source, defect in the equipment, specific event causing noise that is usually absent.
Poor SNR can lead to experiments needing more number of trials, or artifact removal analysis.

.. include:: noise_metrics.rst


KIT Data Quality Dashboard
==========================

This dashboard monitors the quality of the data generated from the KIT-MEG system.
Empty room data is recorded from the KIT system every couple of days, then for each dataset,the metrics are computed.
The results are displayed automatically in the following dashboards.


.. include:: con_files_statistics.rst


*Plot of Average and Variance Over Time*


.. raw:: html

    <iframe src="../_static/average_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/variance_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/max_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/fft_plots_combined.html" width="100%" height="600px" frameborder="0"></iframe>
    



OPM Data Quality dashboard
==========================

.. raw:: html

    <iframe src="../_static/average_plot_opm_data.html" width="100%" height="600px"></iframe>


Perspectives on Data Quality dashboards
=======================================

- checkout the lab manual to define new metrics and threshold
- Whitening the data  compute a noise vector
- optimise the memory usage of process_con_files_for_table.py by cropping the data to 10 seconds only
- migrate the dashboard generation to a dedicated server triggered on file adding
- track dataset files, if one is already processed, avoid redownloading again, unless metrics have been changed