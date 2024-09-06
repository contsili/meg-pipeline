import os
import mne
import matplotlib
import matplotlib.pyplot as plt
import matplotlib

matplotlib.use("TkAgg")  # or can use 'TkAgg', whatever you have/prefer


def display_env_variable(variable_name):
    value = os.getenv(variable_name)
    if value is None:
        print(f"The environment variable '{variable_name}' is not set.")
    else:
        print(f"The value of the environment variable '{variable_name}' is: {value}")
    return value


MEG_DATA = display_env_variable("MEG_DATA")


file_path = (
    "\empty-room\sub-emptyroom\meg-kit\empty-room-test_28_June_2024-raw_NO_OPM-raw.fif"
)

file_path = MEG_DATA + file_path

raw = mne.io.read_raw_fif(file_path)


# # Specify the channel name you want to plot
# channel_name = 'MISC 001'
# raw.pick_channels([channel_name])
# scalings = {'misc':0.1}
raw.plot(start=0, duration=5)

# raw.plot(scalings = scalings, duration=320, start=0, n_channels=1)

plt.show(block=True)
# raw.plot(scalings = scalings, duration=320, start=0, n_channels=1)

# Set a break point next and launch in debug mode
a = 1
