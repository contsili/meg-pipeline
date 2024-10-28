Operational Protocol: KIT
=========================

Lead author: Gayathri Satheesh `gs2750@nyu.edu <gs2750@nyu.edu>`_, Haidee Paterson `haidee.paterson@nyu.edu <haidee.paterson@nyu.edu>`_, Hadi Zaatiti `hadi.zaatiti@nyu.edu <hadi.zaatiti@nyu.edu>`_

Based on a previous version of the protocol from Aniol Santos Angles.


Lab booking and schedule
------------------------

.. warning::

   All bookings should not happen on a monday morning, as Helium refill is scheduled for monday mornings
   and it is not possible to acquire data during this period.


Lab equipment provided to the project owner
-------------------------------------------

The MEG lab is provided to the project owner after the following checks and tests have been made successfully:

#. KIT system is in an operational status
    - Helium levels are sufficient to conduct an experiment
    - Quality of the data from SQUIDs sensor has been verified
    - Empty-room data has been acquired and noise levels has been computed and asessed
        - Empty room data is recorded at 1kHz sampling rate for around 3 minutes every couple of days and made available on NYU-BOX
        - MSR lights are put off during empty-room data recordin and brightness is set to low
        - All phones are on airplane mode
        - The dashboards show the noise levels from empty-room data and are updated automatically on a daily basis
        - If the project owner requires empty-room data on the day of his experiment run, he should make this clear to the lab scientist

#. Vpixx system is operational
    - Trigger events are tested
    - Projector is in a running state
    - Response boxes are running correctly

#. Communication system with participant are operational
    - Microphone outside the MSR, to communicate to the participant works correctly
    - Microphone inside the MSR for participant to communicate with project owner works correctly
    - Earplugs for participant to hear the project owner outisde the MSR works correctly
    - Coming soon: Camera inside MSR for visualising the participant

#. Laser scanner system is operational
    - Laser scanner computer works correctly
    - Laser pointer/surface scanner is operational

#. Scrubs and caps and all hygiene related materials are available
    - earplugs are desinfected
    - caps are available
    - scrubs are available
    - clinical application tape is available for HPI coils on participant face


Prepare the lab equipment (prior to participant arrival) Estimated Time: 20min
------------------------------------------------------------------------------

**Performed by the project owner** by following the order

#. Prepare MSR:
    - Make sure the MSR has no metal objects inside
    - Switch the heater off

    .. figure:: figures/meg-operationprotocol/heater_button.png
        :alt: Heater Button Image
        :align: center

        Heater Button.

    - Prepare bedsheets and pillowcases
    - Clinical Tape is usually stored in the drawers inside the plastic furniture piece inside the MSR
        - or/also in the top right wooden drawer outside the MSR, on the right side of the `Stimulus computer`
    - Prepare 12 pieces of tape, those will be used to set the `HPI coils` on the participant's head

#. Marker box check:
    - Ensure that the `Marker Box` found inside the MSR has enough battery
        - Power up the `Marker Box` by flipping the `Power` switch up
        - If there is enough battery, the red led 'Low battery' should go on for a second and then back off
        - If there is not enough battery, the red led 'Low batter' is either on all the time or never comes on for a second as previously
            - In this case, change the batteries of the Box, recharged batteries are available under the `Eyetracker` computer
    - Unroll the five HPI marker coils that are linked to the `Marker Box`
#. Trigger Box preparation:
    - The `Trigger Box` is outside the MSR and pictured below

    .. figure:: figures/meg-operationprotocol/trigger_box.png
        :alt: Trigger Box
        :align: center

        Trigger Box found above the `MEG Main PC`.

    - Ensure that the `Source` button is set to `PC` which is the left side

#. If project owner requires empty-room data prior to experiment:
    - Turn off the MSR lights and put the light brightness to low
    - Close the MSR door without having any individual inside
    - After the previous steps, on the `MEG Main PC` computer, open `MEG160` software
    - Then, Menu -> Acquire -> Auto Tuning -> Ok
        - Wait for the auto-tuning to be done
    - From Menu -> MEG Measurement -> Monitor and Acquisition window should open
        - Ensure or set (these parameters are only to be used for empty-room data and not for a neuro-activity experiment measurement):
            - LPF to `0.1 Hz`
            - HPF to `1 KHz`
            - BEF to `THRU`
        - Sensor Check
        - Let the `Sensor Check` run for around 2 minutes
        - Make sure that the sensor display identical sinusoidal wave
        - Remind that `Sensor 91` is broken and will not display a sine wave

    - Under ‘Data Acquisition’
    - Patient ID: sub-emptyroom
    - Name: sub-emptyroom_<data in YYYYMMDD>
    - Foldername: C: \MEG160\Bin\emptyroom
    - After ensuring the MSR door is closed, press `Lock`
        - The sensor measurements will oscillate rapidly, wait until the values are stable, i.e., no upward or downward trend is observed
    - Continuous Mode -> Start
        - Set Sampling Rate to 2000 Hz
        - Set Time to `180 seconds`
        - then, `Start Acquisition`
    - When recording is done, press `Unlock`
    - Close the `MEG Measurement` window
    - Open the MSR door

#. Prepare Vpixx systems:
    - Ensure that the three `Vpixx` boxes are turned on: Soundpixx, Propixx and Responsepixx
    - Turn on the computer if it is off, boot under Windows
    - Settings of Vpixx computer. Ensure that
        - The Bar menu is fixed (not disappearing)
            - Right click on the bar menu > Taskbar settings > …
        - Screens are in multiple displays (not mirror display)
            - Right-click on desktop > Display settings > Extend these displays > Keep changes
        - Volume is off (keyboard)
    - Set up Vpixx either through bash script **VPutil** (preferred) or through **PyPixx GUI**
        - Open `Vputil` found on the desktop
        - Run `ppx a` and `Enter`,
        - Check if the screen inside the MSR is on, if the screen is off then:
            - run `ppx s`, then run `reset`, then wait for a minute, run `ppx a`

    - Ensure the orientation (vertical flip) of the screen inside the MSR is correct, if not:
        - Open `Pypixx`, press `Rear Projection`, check again

        .. figure:: figures/meg-operationprotocol/pypixx_icon.png
            :alt: Pypixx icon
            :align: center

            Pypixx icon.

        - Open `Display Settings` on the top left of the GUI
            - Unselect `Ceiling Mount`
            - Select `Rear projection`

            .. figure:: figures/meg-operationprotocol/projection_mode.png
                :alt: Projection Mode
                :align: center

                Projection Mode.

        - Switch on the projector (if not already done via Vputil):
            - Press 'Wake PROPIXX', (when it says 'Sleep PROPixx', it means it is awake)

        - Check whether the projected image in the MSR appears correctly (use text file `PROPIXX_Test_text.txt` found on the desktop)
    - Ensure the image on the Vpixx screen in the MSR room is displaying correctly
    - Response Device
        - Button box: make sure all the optical cables form the button boxes are plugged in correctly as shown in the picture
        - [IMAGE]
        - Dial: make sure that dial is connected to Vpixx computer, and USB button is OFF

#. Microphone inside MSR:
    - Make sure the sound box is switched on, if not click on the green round button
    - Check if you can hear the participant through the speakers, talking from inside the MSR to the microphone (on the left side of the Dewar)
    - [IMAGE]

#. Earplugs
    - Check the earplugs and make sure the participant can hear you
    - [IMAGE]


#. Prepare the `FastScan` computer:
    - If the `FastScan` computer is not turned on:
        - make sure that FastScan device is off (the flat black box next to the monitor, picture below)
        - then turn on the computer then launch `FastScanII` program
        - then turn on the FastScan device

        .. figure:: figures/meg-operationprotocol/fast_scan_device.png
            :alt: Fast Scan device
            :align: center

            FastScan device.


#. Verify your experiment script:
    - If using `PsychToolBox`:
        - Open MATLAB
        - Access your experiment `.m` script and launch it
        - Make sure you arrive to the `Introduction Page` mentioned in the :ref:`design_experiment` section
    - You can make a quick test run to make sure that trigger signals are appearing correctly on the `MEG160` software


Perform the MEG Experiment (Participant is present)
---------------------------------------------------

#. Welcoming the participant and providing them with explanations
    - [WELCOME] Thank you for joining our study. Is this your first time in the MEG?
    - [GENERAL OVERVIEW] No worry, Let me explain to you now what we are going to do today.
    - [BEFORE MEG - HEAD SHAPE] Before you are going into the MEG, we need to do some preparation.
    - Explain the FastScan head laser scan:
        - I will scan your head shape with a laser gun [show the FastScan]
        - This is giving us a 3D reconstruction of the shape of your head
        - To do that, you need to sit there and not move for around 5-7 minutes
        - Moreover, I have to mark five points on your forehead and close to your ears with this [show it] washable ink,
        - it will disappear after just one shower [show the phantom head with the points]
        - Why are we doing that? To know where your head is located while you are in the MEG.
        - This is important for the study we are running because we need to know where the data recorded by the MEG sensors
        - that measure the tiny changes in the magnetic field generated by the brain activity, is coming from.
        - You know, different people have different head shape/size,...
        - and they place the head in slightly different sites relative to the MEG sensors.
        - Why the points? When we are in the MEG room
        - I will tape you small things called ‘head position coils’ in the places you have these painted points
        - and this will tell us where your head is relative to the MEG sensors
        - It looks a bit weird at the beginning, but you get used to it soon(I did the experiment on myself)
        - [BEFORE MEG - CLOTHES]
            - Another important thing is that you cannot go inside of the MEG room with any kind of metallic object
            - because it will create an artifact on the MEG sensors.
            - To ensure that, I have to ask you to wear this MEG compatible clothes (like the ones in the hospitals).
            - Please, if you feel comfortable with that, you should take off your bra (most of the time there are small metallic trips or parts).
        - [INSIDE MEG]
            - Explain the study-specific instructions here or give them an instruction manual to read.\
            - Now, let me recap what we will do today. You need to fill the forms, scan your brain shape,
            - then you need to change clothes. You go to the MEG room, we tape coils in your  forehead. And then, you will do the tasks.
        - [END OF EXPLANATION] Is everything clear? Do you have any questions? Do you feel comfortable? Are you ok? Please let me know, this is important for us that you understand everything.

#. Fill up forms
    - Ensure that we have the electronically signed two consents. If not, make the participant sign by hand [LINK]
    - Fill up contact, demographic, and handness forms [LINK]

#. Check up MEG incompatibilities
    - Make participant change their clothes by hospital clothing (scrubs), keeping underwear and socks (not bra)
    - Make sure they have NO metallic objects in the body/eyes
        - Surgery? Surgical clip, artificial heart valve, implanted drug pump
        - Bullet
        - Cochlear implant or hearing aid
        - Make-up, especially red color makeup
        - Hair pins
        - Jewelry
        - Keys
        - Phone
    - If the subject arrives with make-up, ask him/her to completely remove it
    - Ask the participant to put their phone on Airplane mode

#. Perform the FastScan laser head scan
    - Capping the participant
        - Put the 'pink' swimming cap on the head of the person
        - Make sure the cap is as smooth as possible on the participant's head
        - People with long hair, can keep most part of their hair outside the cap behind their ears and onto the back
        - The ears must be clear of hair
        - The cap must cover all the hair that can be seen at the anterior, left and right parts of the head
        - The goal is that the cap takes the shape of the skull at best
    - Mark the fiducials
        - Use the “T” template, with the line aligning the participant’s nasion as in the below picture

        .. figure:: figures/meg-operationprotocol/template_nasion.png
            :alt: Template and Nasion
            :align: center

            "T" template on the right and nasion/pre(auricular) positions on the left.

        - Mark the nasion using a pen (fiducial 1)
        - Adjust the "T" template to the participants nasion
        - Using a pen marker, mark fiducials 6, 7 and 8 by using the three holes in the "T" template

        .. figure:: figures/meg-operationprotocol/fiducials.png
            :alt: Fiducials
            :align: center

            Fiducials numbered by the order they should be laser scanned with.

        - Mark the left and right pre-auriculars (1cm anterior to the tragi) and the right and left auriculars
        - Put on the neck brace
            - Place a tissue over the area closest to the mouth on the neck brace for sanitary purposes - see picture

        .. figure:: figures/meg-operationprotocol/neckbrace.png
            :alt: Neck brace with tissue for sanitary purposes
            :align: center

            Neck brace with tissue for sanitary purposes.

    - Perform laser scan
        - Once FastScan is finished initializing (indicated at the bottom of the software UI):
            - Ask the participant to close their eyes and avoid any movements until scan is finished
            - Open `FastScan II` software on the computer
            - Press 'New'
            - Ensure the scanner is in Sweep mode (add [IMAGE])
            - Point the laser gun at the stationary point (the box on the ring you place around the neck, [IMAGE]) with a half-click, followed by a full click.
            - Scan head shape (sweeps) with full click. Tips:
                - All cap surface + surfaces with fiducial points
                - Avoid overlapping sweeps
                - Making sweeps for head and face separately.
                - Keep a consistent distance between the head and scanner.



#. Big steps:
    #. Laser Scan of the head: participant head scan, stylus marking on head Output: surface
    #. Participant in the MSR:
        #. Attach the HPI coils to the participant
    #. Experiment being run
        #. Attach the HPI coils to the participant experiment conducted
    #. Participant outside the MSR, experiment finished, back to normal clothes

#. Wake HeadScan computer system in preparation room

#. Prepare rooms:
   - Fresh linen
   - Clear tape
   - Earbuds inside MSR
   - Camera monitor on
   - For female participants: sign on door, block door

#. Take participant’s informed consent, demographics

#. Change participant into scrubs

#. Seat participant in static chair. Mark the face for laser point marking (1-7) for placement of markers inside the MSR

#. Scan the head with HeadScan computer and register laser points 1-7

#. Phones in airplane mode, heater off, call security to request they switch off their radios

   You are now ready to take the participant into the MSR

#. Inside the MSR:
   - Power on marker box (please check if it powers on – it is powered by 4 rechargeable AA batteries and sometimes require changing)
   - Place 5 markers on face in correctly corresponding positions
   - Lay participant down with comfort pad under knees and position head inside KIT
   - Clean earbuds in participants ears (using appropriate system – Vpixx or Legacy)
   - Left or Right Button (VPixx or Legacy) boxes in participants corresponding hand (depending on requirement of experiment)

#. This is the most important step in setting up:

   **CLOSE AND LOCK THE MSR DOOR**

#. Open MEGLab:
    - Acquire -> Autotuning

#. Acquire -> MEG Measurement

#. Lock sensors [is MSR door locked?] Evaluate signal quality

#. Do a Marker measurement. If results are above 90%, you are good to go.

#. Start continuous to begin recording of MEG signal

#. On Stimulus2 Computer:
    - Navigate to Experiments

#. MEGLab:
    - When experiment is done - Click Abort to stop recording

#. Do one last Marker measurement

   **UNLOCK SENSORS BEFORE OPENING THE MSR DOOR**

Participant can now be removed from the KIT



Noise reduction of the .con data
--------------------------------

Open the .con file in the default app `MEG160` then apply a Noise Reduction filter using Edit -> Noise Reduction
Make sure the Magnetometers on channels 208, 209, 210 are used.
Execute the noise reduction, then File -> Save As -> add `_NR` at the end of the file name.
Transfer both files to NYU BOX as detailed in the data uploading section.


Stylus location and markers
---------------------------

.. image:: ../graphic/markers1.jpeg
  :width: 400
  :alt: AI generated MEG-system image

.. image:: ../graphic/markers2.jpeg
  :width: 400
  :alt: AI generated MEG-system image


The following table sumarises the position of each registered stylus location and whether or not a KIT coil will be placed on that position.

+-------+-----------------+--------------------------------------+
| Index | Body Part       | Marker Coil Information              |
+=======+=================+======================================+
| 1     | Nasion          | KIT: NO, OPM:                        |
+-------+-----------------+--------------------------------------+
| 2     | Left Traps      | KIT: NO, OPM:                        |
+-------+-----------------+--------------------------------------+
| 3     | Right Traps     | KIT: NO, OPM:                        |
+-------+-----------------+--------------------------------------+
| 4     | Left Ear        | KIT: YES, OPM:                       |
+-------+-----------------+--------------------------------------+
| 5     | Right Ear       | KIT: YES, OPM:                       |
+-------+-----------------+--------------------------------------+
| 6     | Center Forehead | KIT: YES, OPM:                       |
+-------+-----------------+--------------------------------------+
| 7     | Left Forehead   | KIT: YES, OPM:                       |
+-------+-----------------+--------------------------------------+
| 8     | Right Forehead  | KIT: YES, OPM:                       |
+-------+-----------------+--------------------------------------+


Marker coils for KIT order of appearence in .mrk
------------------------------------------------

The registered `.mrk` file containing the position of the HPI coils for KIT.
Using `fieldtrip` function named `ft_read_headshape('PATH TO .mrk')`, we report the order of appearence
of the HPI coils positions in the `.mrk` file below.
This has been tested with many `.mrk` files in the current pluggin setting (last column)

+----------------------+-----------------------------+-------+---------------------+
| Order of appearance  | Placing position of HPI     | Color | Plugging order      |
| in the .mrk          | Coil on head                |       | in Marker Box       |
+======================+=============================+=======+=====================+
| 1                    | Central Forehead (CF)       | Blue  | 2                   |
+----------------------+-----------------------------+-------+---------------------+
| 2                    | Left Ear (LE)               | Red   | 0                   |
+----------------------+-----------------------------+-------+---------------------+
| 3                    | Right Ear (RE)              | Yellow| 1                   |
+----------------------+-----------------------------+-------+---------------------+
| 4                    | Left Forehead (LF)          | White | 3                   |
+----------------------+-----------------------------+-------+---------------------+
| 5                    | Right Forehead (RF)         | Black | 4                   |
+----------------------+-----------------------------+-------+---------------------+











Operational Protocol: OPM
=========================

There are three ways to coregister with OPM:

way 1: laser scan the participants head and stylus points, then place participant in helmet, then laser scan the fiducials on the face again, followed by the 8 points on the OPM
(Check if the laser scanner would work with the OPM 8 points) (this way assumes that the participant is not moving their head within the OPM helmet)

way 2: laser scan the participant head and stylus points, then place the participant in helmet, then place HPI coils on known stylus points (must standardize those locations).
In this case, a script must be ran at beginning and end of the experiment to energize the coils with sinusoidal waves of known frequencies (follow up with fieldtrip tutorial section 2)

way 3: laser scan the participant, mark fiducials, then place participant in helmet, laser scan everything, mark fiducials
Coregister both set of fiducials



Training to become an MEG authorized operator
=============================================

A project owner can be trained by the MEG lab scientists to become an authorized operator.
Over the course of a day, they will be taught about the operation protocol described above, the emergency procedures to perform, the safety rules to folow and any
operation that must be done in the lab prior/post data acquisition.

Once the training is performed, the following form should be submitted to the MEG lab scientists.

.. note::
    `Access to training attendance form <https://docs.google.com/forms/d/e/1FAIpQLScLW1MOvo-9aAwX2_04FcyLGPR9xtDso9hu9SEixUy2VzuAiw/viewform>`_




