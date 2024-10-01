EEG-fMRI system Operational Protocol
====================================

This page provides data on the operational protocol for the EEG-fMRI system at NYUAD.
The protocol describes the data acquisition process.




Activation of the product is done
---------------------------------
- The current activation licenses are for one week (we need permanent licenses).
- The permanent licenses are on two dongles and electronic ones in Haidee’s email.

Summary:
--------
- Physical interface of the hardware:
  - Two amps connected to battery power supply and also to the Syncbox through fiber optics.
  - Battery power supply must be charged after each experiment.
  - Recording computer is connected via two USB cables to the Syncbox.
  - The recording computer can be put in the EEG mockup room to prepare participants prior to an experiment.

An EEG/fMRI study should start:
-------------------------------
- Collect EEG data in a static field to identify artifacts and remove them in post-processing.

Each EEG-FMRI dataset contains:
-------------------------------
- An .eeg file: raw data from the electrodes.
- A .vhdr or .xhdr file: a header containing metadata on parameters and sensors.
- A .xmrk file: contains markers with their time (can be opened in a text file).



.. image:: figures/gradient-artifacts.png
  :width: 400
  :alt: AI generated MEG-system image

Pre-processing steps should involve:
------------------------------------
1. Inspecting the static field data.
2. Gradient-artifact correction.
3. ECG correction or CWL regression (Cardioballistic artifacts).
4. Classic EEG analysis.






Helium Pump Noise:
------------------
- Components around the 50Hz frequency should appear in all channels.
- The helium pumps cannot be turned off during an experiment.

Ventilation System:
-------------------
- Usually causes a higher peak at 50Hz in FFT, with more spread-out noise across high-frequency components.

Markers and Timing Verification:
---------------------------------
- **Marker Verification** needs to be downloaded separately.
- If max and min in marker verification are very far apart, it means a marker is missing.

Gradient Artifact:
------------------
- Occurs during fMRI data acquisition (while acquiring volume).
- In Analyzer, use **average artifact subtraction** to remove the gradient artifact.

ECG Removal:
------------
- The subtraction method can work better than ICA.

Steps for Noise Removal and Pre-processing:
-------------------------------------------
1. Gradient artifact correction:
   - Always remove gradient artifacts first.
   - ECG with gradient artifacts can be saturated; this might require moving the ECG sensor.
   - Ensure markers are synchronized (e.g., R128 markers for MRI).
2. MRI artifact correction:
   - Ensure the correction is applied only during specific triggers.
   - Enable baseline correction for average (compute baseline over the whole artifact).
   - Use sliding average calculation to account for gradient artifact changes over time.
   - Deselect common use of all channels for bad intervals and correlation.
3. ECG signal correction after gradient artifact cleaning:
   - Apply a high cutoff filter to remove high-frequency noise.
   - Mark R peaks manually if the automatic analyzer skips them.
4. CB correction:
   - Use markers (R markers) and compute time delay using whole data.

Carbon Wired Loops (CWL):
-------------------------
- Account for movement correction.
- Downsample the data, then apply CWL regression.

Automating the process:
-----------------------
- Save all analysis steps for automation.
