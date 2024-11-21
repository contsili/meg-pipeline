Cognitive Neuroscience class MEG demonstration
==============================================

Place and time: MEG lab in A2-008 at the 29th of November 2024, from 9:15 am to 10:40 am

Agenda 55min
------------

.. dropdown:: Lab tour and general equipment presentation `10min`

    - MEG overview
    - Explain the dewar, SQUIDs sensors, liquid Helium system
    - Explain the MSR (Magnetically Shielded Room)
    - Show the computers layout and the different capabilities of the lab (eyetracker, vpixx triggers, response box, audio stimulus)
    - Present what experiments we will run on this day and the outline of the demonstration

.. dropdown:: Prepare the participant for an MEG experiment `20min`

    - Perform laser scan of headhape on the participant
    - Place participant in MSR, explain the headcoils placed on participant head
    - Perform auditory check for safety

.. dropdown:: SQUID sensors demonstration `5min`

    - Show sensitivity to noise, rapid eyeblinks, teeth pressure, phone in airplane mode on and off
    - Show marker measurement and explain their importance for source localization
    - Show reference magnetometers and explain denoising for external noise

.. dropdown:: Two demonstrations: Resting state and Auditory vs Visual `50min`

    - Experiment 1: `Resting state: Access link to code and description <../../3-experimentdesign/experiments/1-exp-resting-state.rst>`_ `25min`
        - Two blocks: a block of 10min eyes open and a second block of 10min eyes closed
    - Experiment 2: `Auditory vs Visual: Access link to code and description <../../3-experimentdesign/experiments/9-auditory-vs-visual.rst>`_ `25min`
        - A random sequence of two types of stimulus: auditory 300 Hz stimulus and visual (white flash)


.. dropdown:: Show and discuss analysis results `15min`

    - Experiment 1: `Resting state: Access link to Analysis Notebook <../../5-pipeline/notebooks/mne/resting_state_pipeline.ipynb>`_
        - Show higher alpha power in eyes closed than in eyes open in the alpha band (8-12Hz)
        - Show that this difference is better seen in the occipital region
    - Experiment 2: `Auditory vs Visual experiment`
        - Show auditory trials activating the auditory cortex
        - Show visual trials activating the visual cortex


