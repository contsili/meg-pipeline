Operational Protocol: KIT
=========================
Lead author: Haidee Paterson `haidee.paterson@nyu.edu <haidee.paterson@nyu.edu>`_


Prepare the lab equipment
-------------------------

#. Check KIT system operation status

#. Ensure Helium level is sufficient

#. Get empty room data and check noise levels

#. On the Stimulus2 Computer:
   - Wake Vpixx
   - Run test script
   - Ensure the image on the Vpixx screen in the MSR room is displaying correctly



Experiment Procedure for KIT
----------------------------



#. Prior to arrival, participant is assumed to have no implants, no retainer, no pace-maker, big tattoos
#. Participant goes into the lab and asked to change their clothes to scrubs
#. Ask them to put their phone on Airplane mode
#. Ask them to remove any Jewlry, metallic things, Red Nail polish ideally to be removed, glasses

#. Big steps:
    #. Laser Scan of the head: participant head scan, stylus marking on head Output: surface
    #. Participant in the MSR:
        #. Attach the HPI coils to the participant
experiment conducted
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




