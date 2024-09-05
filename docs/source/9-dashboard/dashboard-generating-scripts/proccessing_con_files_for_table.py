""" This script loads already downloaded .con files and then computes for each one of them, the metrics and saves them in a .csv"""

import os
import numpy as np
import pandas as pd
import mne
import re
from datetime import datetime
import plotly.graph_objects as go
import traceback
import sys


def threshold(threshold, value_data):
    return "🟢 In the threshold" if value_data < threshold else "🔴 Above the threshold"


def process_con_file(file_path):
    try:
        # 3 set to be the Threshold
        s_avg = 3
        # add other matrixs here
        s_fft = 10

        # Load the .con file using MNE
        raw = mne.io.read_raw_kit(file_path, preload=True)
        raw.pick_types(meg=True, eeg=False)
        raw = remove_zero_channels(raw)

        # Get data for all channels
        data, times = raw.get_data(return_times=True)
        sfreq = raw.info["sfreq"]
        freqs, fft_data = compute_fft(data, sfreq)
        print(f"Processing file: {file_path}")
        print(f"Data shape: {data.shape}")
        # Calculate average, variance and find the maximum across all channels
        avg = (np.mean(data)) * 1e15
        var = np.var(data)
        max_val = np.max(data) * 1e15
        # Status for avg
        status_avg = [
            (f"🟢 In the threshold" if avg < s_avg else f"🔴 Above the threshold")
        ]
        # Status for fft
        status_fft = [
            (f"🟢 In the threshold" if var < s_avg else f"🔴 Above the threshold")
        ]
        # status for max
        status_max = [
            (f"🟢 In the threshold" if max_val < s_avg else f"🔴 Above the threshold")
        ]

        return avg, var, max_val, status_avg, freqs, fft_data, status_fft, status_max
    except Exception as e:
        tb = traceback.format_exc()
        failed_function_name = traceback.extract_tb(sys.exc_info()[2])[-1].name
        print(f"Error in function '{failed_function_name}': {e}")
        print(f"Traceback: {tb}")
        return None


# for negative values: tried looking at the channels of the files that give negative  values found some of them provide negative values


def process_all_con_files(base_folder):
    results = []

    try:
        for root, _, files in os.walk(base_folder):
            for file in files:
                if file.endswith(".con"):
                    file_path = os.path.join(root, file)
                    (
                        avg,
                        var,
                        max_val,
                        status,
                        freqs,
                        fft_data,
                        status_fft,
                        status_max,
                    ) = process_con_file(file_path)
                    date = extract_date(file)
                    details = "Nothing added yet"
                    date_str = (
                        date.strftime("%d-%m-%y %H:%M:%S") if date else "Unknown Date"
                    )
                    results.append(
                        {
                            "File Name": file.split("_")[1],
                            "Status for average values": status,
                            "Average": avg,
                            "Variance": var,
                            "Status for max values": status_max,
                            "Maximum": max_val,
                            "Date": date_str,
                            "Details": details,
                        }
                    )

        return results
    except Exception as e:
        tb = traceback.format_exc()
        failed_function_name = traceback.extract_tb(sys.exc_info()[2])[-1].name
        print(f"Error in function '{failed_function_name}': {e}")
        print(f"Traceback: {tb}")
        return None


def save_results_to_csv(results, output_file):
    try:
        # Ensure the directory exists
        os.makedirs(os.path.dirname(output_file), exist_ok=True)

        # Save results to CSV
        df = pd.DataFrame(results)
        df.to_csv(output_file, index=False)
    except Exception as e:
        tb = traceback.format_exc()
        failed_function_name = traceback.extract_tb(sys.exc_info()[2])[-1].name
        print(f"Error in function '{failed_function_name}': {e}")
        print(f"Traceback: {tb}")


def extract_date(filename):
    # Split the filename by underscores and take the first part
    date_str = filename.split("_")[0]

    # Patterns to match different date formats with time
    patterns = [
        r"(\d{2})-(\d{2})-(\d{2})-(\d{2})-(\d{2})-(\d{2})",
    ]

    for pattern in patterns:
        match = re.match(pattern, date_str)
        if match:
            try:
                if len(match.groups()) == 6:
                    if pattern == r"(\d{2})-(\d{2})-(\d{2})-(\d{2})-(\d{2})-(\d{2})":
                        day, month, year, hour, minute, second = match.groups()
                        date_str = f"{day}-{month}-{year} {hour}:{minute}:{second}"
                        return datetime.strptime(date_str, "%d-%m-%y %H:%M:%S")
            except ValueError:
                continue

    return None


def plot_data_avg(csv_file, output_html):
    try:
        # Load data from CSV
        df = pd.read_csv(csv_file)

        # Ensure 'Date' column is in datetime format
        df["Date"] = pd.to_datetime(
            df["Date"], format="%d-%m-%y %H:%M:%S", errors="coerce"
        )
        df = df.sort_values(by="Date")

        # Create figure
        fig = go.Figure()

        # Add line plot for Average
        fig.add_trace(
            go.Scatter(
                x=df["Date"],
                y=df["Average"],
                mode="markers",
                line=dict(color="blue"),
                marker=dict(color="blue", size=8),
                name="Average",
            )
        )

        # Update layout
        fig.update_layout(
            title="Average Over Time",
            xaxis_title="Date",
            yaxis_title="Average Value(fT)",
            legend_title="Metrics",
        )

        # Save plot as HTML
        fig.write_html(output_html)
        print(f"Plot saved to {output_html}")
    except Exception as e:
        print(f"Error processing: {e}")


def remove_zero_channels(raw):
    data = raw.get_data()
    non_zero_indices = np.any(data != 0, axis=1)
    # print(non_zero_indices)
    raw.pick_channels(
        [raw.ch_names[i] for i in range(len(non_zero_indices)) if non_zero_indices[i]]
    )
    return raw


def plot_data_var(csv_file, output_html):
    # Load data from CSV
    df = pd.read_csv(csv_file)

    # Ensure 'Date' column is in datetime format
    df["Date"] = pd.to_datetime(df["Date"], format="%d-%m-%y %H:%M:%S", errors="coerce")
    df = df.sort_values(by="Date")

    # Create figure
    fig = go.Figure()

    # Add line plot for Variance
    fig.add_trace(
        go.Scatter(
            x=df["Date"],
            y=df["Variance"],
            mode="markers",
            line=dict(color="grey"),
            marker=dict(color="grey", size=8),
            name="Variance",
        )
    )

    # Update layout
    fig.update_layout(
        title="Variance Over Time",
        xaxis_title="Date",
        yaxis_title="Value",
        legend_title="Metrics",
    )

    # Save plot as HTML
    fig.write_html(output_html)
    print(f"Plot saved to {output_html}")


def plot_data_max(csv_file, output_html):
    # Load data from CSV
    df = pd.read_csv(csv_file)

    # Ensure 'Date' column is in datetime format
    df["Date"] = pd.to_datetime(df["Date"], format="%d-%m-%y %H:%M:%S", errors="coerce")
    df = df.sort_values(by="Date")

    # Create figure
    fig = go.Figure()

    # Add line plot for Average
    fig.add_trace(
        go.Scatter(
            x=df["Date"],
            y=df["Maximum"],
            mode="markers",
            line=dict(color="blue"),
            marker=dict(color="blue", size=8),
            name="Maximum",
        )
    )

    # Update layout
    fig.update_layout(
        title="Maximum Over Time",
        xaxis_title="Date",
        yaxis_title="Maximum Value(fT)",
        legend_title="Metrics",
    )

    # Save plot as HTML
    fig.write_html(output_html)
    print(f"Plot saved to {output_html}")


def compute_fft(data, sfreq):
    fft_data = np.fft.rfft(data, axis=-1)
    freqs = np.fft.rfftfreq(data.shape[-1], d=1 / sfreq)
    return freqs, np.abs(fft_data)


try:
    # Set the base folder containing .con files and subfolders
    base_folder = r"data"
    # Set the output CSV file path
    output_file = "9-dashboard/data/con_files_statistics.csv"

    # Process all .con files and save the results
    results = process_all_con_files(base_folder)
    save_results_to_csv(results, output_file)

    print(f"Results saved to {output_file}")
    # print(results)

    csv_file = output_file  # Path to the CSV file
    output_avg_html = "_static/average_plot.html"  # Path to save the HTML file

    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_avg_html), exist_ok=True)

    # Create and save the plot
    plot_data_avg(csv_file, output_avg_html)

    output_variance_html = "_static/variance_plot.html"  # Path to save the HTML file

    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_variance_html), exist_ok=True)

    # Create and save the plot
    plot_data_var(csv_file, output_variance_html)
    output_variance_html = "_static/max_plot.html"
    plot_data_max(csv_file, output_variance_html)
except:
    print(f"Error processing")
########################################################################
import glob
import plotly.graph_objs as go

fig = go.Figure()
con_files = glob.glob(r"data/*.con")
for con_file in con_files:
    try:
        raw = mne.io.read_raw_ctf(con_file, preload=True)
        psds, freqs = mne.time_frequency.psd_welch(raw, n_fft=2048)

        fig.add_trace(
            go.Scatter(x=freqs, y=psds.mean(axis=0), mode="lines", name=con_file)
        )
    except Exception as e:
        print(f"Error processing {con_file}: {e}")

fig.update_layout(
    title="FFT Plots for Multiple .con Files",
    xaxis_title="Frequency (Hz)",
    yaxis_title="Power Spectral Density (dB)",
)
fig.write_html("_static/fft_plots_combined.html")
print("fft plot saved!")

################################################################################
import plotly.express as px
import plotly.graph_objs as go
from plotly.subplots import make_subplots


def process_fifo_files(base_folder, output_file):
    # List to store file names, averages, and variances
    data = []

    # Iterate over all files in the base_folder
    for filename in os.listdir(base_folder):
        if filename.endswith(".fifo"):
            file_path = os.path.join(base_folder, filename)

            try:
                # Read data from the .fifo file
                with open(file_path, "r") as file:
                    data_lines = file.readlines()

                # Convert data to a list of floats
                values = [float(line.strip()) for line in data_lines if line.strip()]

                # Calculate average and variance
                mean = sum(values) / len(values)
                variance = sum((x - mean) ** 2 for x in values) / len(values)

                # Append the results to the data list
                data.append([filename, mean, variance])

                print(f"Processed {filename}: Mean={mean:.2f}, Variance={variance:.2f}")

            except Exception as e:
                print(f"Error processing {filename}: {e}")

    # Convert the data list to a DataFrame
    df = pd.DataFrame(data, columns=["Filename", "Average", "Variance"])

    # Create a plot with Filename on the x-axis and both Average and Variance on the y-axis
    fig = make_subplots(specs=[[{"secondary_y": True}]])

    fig.add_trace(
        go.Bar(x=df["Filename"], y=df["Average"], name="Average"),
        secondary_y=False,
    )

    fig.add_trace(
        go.Bar(x=df["Filename"], y=df["Variance"], name="Variance"),
        secondary_y=True,
    )

    # Update layout for better readability
    fig.update_layout(
        title="Average and Variance of FIFO Files",
        xaxis_title="Filename",
        yaxis_title="Average",
        yaxis2_title="Variance",
        barmode="group",
    )

    # Save the plot as an HTML file
    fig.write_html(output_file)


base_folder = r"data/meg-opm"
output_file = r"docs/source/_static/average_plot_opm_data.html"
process_fifo_files(base_folder, output_file)
