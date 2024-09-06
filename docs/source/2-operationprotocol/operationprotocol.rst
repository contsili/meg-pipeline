Operation Protocol: KIT
=======================
Lead author:


Advice to participants: 1.	Don’t bring any magnetic things (e.g., a magnet) into the MSR.
Strong magnetic fields may cause damage to the MEG sensors.

Step 1 is to acquire a scan of the head surface generating a .ext (to be added) file for the participant

.. raw:: html
    :file: ../graphic/operation_protocol.drawio.html


Step 2 is to

.. raw:: html
    :file: ../graphic/meg_data_generation.drawio.html



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
| 1     | Nosion          | KIT: NO, OPM:                        |
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



Operation Protocol: OPM
=======================

There are three ways to coregister with OPM:

way 1: laser scan the participants head and stylus points, then place participant in helmet, then laser scan the fiducials on the face again, followed by the 8 points on the OPM
(Check if the laser scanner would work with the OPM 8 points) (this way assumes that the participant is not moving their head within the OPM helmet)

way 2: laser scan the participant head and stylus points, then place the participant in helmet, then place HPI coils on known stylus points (must standardize those locations).
In this case, a script must be ran at beginning and end of the experiment to energize the coils with sinusoidal waves of known frequencies (follow up with fieldtrip tutorial section 2)

way 3: laser scan the participant, mark fiducials, then place participant in helmet, laser scan everything, mark fiducials
Coregister both set of fiducials







