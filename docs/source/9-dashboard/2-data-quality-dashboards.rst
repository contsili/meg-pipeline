Data Quality Dashboards
#######################

An MEG signal is a tiny magnetic fields, in the order of 100 fT, where
femtotesla  :math:`1fT = 10^{-15} T` and picotesla :math:`1pT = 10^{-12} T`.

EEG scalp signals are about 50 to 100 :math:`\mu\text{V}`


Several metrics are defined in the below table and will serve as basis to asess the quality of data.

.. include:: noise_metrics.rst

.. include:: con_files_statistics.rst

KIT Data Quality Dashboard
==========================

This dashboard monitors the quality of the data generated from the KIT-MEG system.
Several metrics can be measured using empty-room data to ensure high Signal to Noise Ratio (SNR).

- Some parLook in the lab manual to see the data quality
- Whitening the data  compute a noise vector
- Poor SNR, can lead to experiments needing more number of trials
- In language studies, much more trials are needed because the activation of the brain regions are more subtle



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