import mne


file_path = 'emptyroom_11.con'

raw = mne.io.read_raw_kit(file_path, preload=False, verbose=False)

