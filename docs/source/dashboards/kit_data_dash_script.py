import os
import mne
from dash import Dash, html, dcc, Input, Output, callback
import pandas as pd
from mne.io.kit import read_raw_kit
import numpy as np
import plotly.graph_objs as go
import plotly.io as pio
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import plotly.express as px
import random

directory_path = "data/kit_data"
i = 0


# get data and file's bame from .con files
def process(file_path):
    # this works for .fifo files but what about .con?

    # raw = mne.io.read_raw_fif(file_path)
    # raw.plot(start=0, duration=5)
    file_data = "empty for now"
    # place holder
    file_name = os.path.basename(file_path).split(".")[0].replace("-", " ")
    return file_data, file_name


# fonction for .con files
def remove_zero_channels(raw):
    data = raw.get_data()
    non_zero_indices = np.any(data != 0, axis=1)
    print(non_zero_indices)
    raw.pick_channels(
        [raw.ch_names[i] for i in range(len(non_zero_indices)) if non_zero_indices[i]]
    )
    return raw


# display table for one chanalle
def display_table(status, system_name):
    # display green and red dots
    colored_status = [
        (
            f'<span style="color: green;">•</span> {s}'
            if s == "Active"
            else f'<span style="color: red;">•</span> {s}'
        )
        for s in status
    ]

    # Create the table
    fig = go.Figure(
        data=[
            go.Table(
                header=dict(
                    values=["Status", "System Name"],
                    fill_color="paleturquoise",
                    align="left",
                ),
                cells=dict(
                    values=[colored_status, system_name],
                    fill_color="lavender",
                    align="left",
                    font=dict(family="Arial", size=14),
                ),
            )
        ]
    )
    return fig


# display graph for one chanalle time series
def display_graph(daily_avg_snr, data_time):
    return fig


# changing chanlles
def change_channels(channels_list):
    channels = channels


# get all data and file names
for filename in os.listdir(directory_path):
    files_names = []
    files_data = []
    if filename.endswith(".con"):
        file_path = os.path.join(directory_path, filename)
        i = i + 1
        file_data, file_name = process(file_path)
        files_names.append(file_name)
        files_data.append(file_data)

        print(file_name)

# create data frame for all the data by file name
df = pd.DataFrame({"file_name": files_names, "feature_n_exp_snr": files_data})

# file_path = "data/kit_data/empty-test.con"
# raw_data = read_raw_kit(input_fname=file_path)

# # Load data and remove zero channels
# raw_data = load_fif_data(file_path)
# raw_data = remove_zero_channels(raw_data)


###############fake############################
def generate_fake_data(start_date, end_date, num_entries):
    date_range = pd.date_range(start_date, end_date, freq="H").to_list()
    fake_data = []

    for _ in range(num_entries):
        snr_time = random.choice(date_range)
        snr_avg = random.uniform(5, 15)  # Generating random SNR values between 5 and 15
        fake_data.append((snr_time, snr_avg))

    return fake_data


# Generate fake data
start_date = "2025-10-10"
end_date = "2025-10-20"
num_entries = 10
fake_data = generate_fake_data(start_date, end_date, num_entries)

# Create a DataFrame
df = pd.DataFrame(fake_data, columns=["SNR_Time", "SNR_Avg"])

status = ["Active", "Inactive", "Active", "Inactive"]
system_name = ["System A", "System B", "System C", "System D"]
###############################################
# Convert SNR_Time to datetime and extract the date
df["SNR_Time"] = pd.to_datetime(df["SNR_Time"])
df["Date"] = df["SNR_Time"].dt.date

# Group by date and calculate the average SNR
daily_avg_snr = df.groupby("Date")["SNR_Avg"].mean().reset_index()

# Create a plot
fig = go.Figure(
    [
        go.Scatter(
            x=daily_avg_snr["Date"], y=daily_avg_snr["SNR_Avg"], mode="lines+markers"
        )
    ]
)
fig2 = display_table(status, system_name)
fig.update_layout(
    title="Average Daily SNR", xaxis_title="Date", yaxis_title="Average SNR"
)
fig.write_html(
    "C:/Users/Admin/meg-pipeline/docs/source/_static/figure_time_series_test.html"
)
fig.write_html("C:/Users/Admin/meg-pipeline/docs/source/_static/plotly_dashboard.html")


fig2.write_html(
    "C:/Users/Admin/meg-pipeline/docs/source/_static/figure_table_test.html"
)

##############
###SNR#####
#############
