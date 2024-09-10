"""
This script loads already downloaded .con files and then computes for each
one of them, the metrics and saves them in a .csv
"""

import os
import sys
from datetime import datetime

import logging
import traceback

import tracemalloc


import numpy as np
import pandas as pd
import mne
import re
import plotly.graph_objects as go


# Start tracing memory allocation
tracemalloc.start()




def threshold(threshold, value_data):
    return "🟢 In the threshold" if value_data < threshold else "🔴 Above the threshold"


def process_con_file(file_path):
    try:
        # 3 set to be the Threshold
        s_avg = 3
        # add other matrices here
        s_fft = 10

        logging.info(f"Processing file: {file_path}")
        # Load the .con file using MNE
        raw = mne.io.read_raw_kit(file_path, preload=False, verbose=False)
        raw.pick(picks="meg")

        data_duration = raw.times[-1]

        if TMAX <= data_duration and TMIN <= data_duration:
            # Crop data:
            raw = raw.crop(TMIN, TMAX)
            logging.info(f"Cropped data for: {file_path}")

        raw = remove_zero_channels(raw)

        # Get data for all channels
        data = raw.get_data()

        #logging.info(f"Processing file: {file_path}, Data shape: {data.shape}")
        sfreq = raw.info["sfreq"]
        freqs, fft_data = compute_fft(data, sfreq)

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
        logging.info(f"Error in function '{failed_function_name}': {e}")
        logging.info(f"Traceback: {tb}")
        return None


# for negative values: tried looking at the channels of the files that give negative  values found some of them provide negative values


def process_all_con_files(base_folder, file_limit=None):
    """ """
    results = []
    file_count = 0  # Initialize a counter

    try:
        for root, _, files in os.walk(base_folder):
            for file in files:
                if file.endswith(".con"):
                    processing_state = "UNPROCESSED"
                    file_path = os.path.join(root, file)

                    result = process_con_file(file_path)
                    if result is None:
                        logging.info(f"Processing failed for {file_path}")
                    else:
                        # Process the file
                        (
                            avg,
                            var,
                            max_val,
                            status,
                            freqs,
                            fft_data,
                            status_fft,
                            status_max,
                        ) = result

                        # Extract date
                        date = extract_date(file)
                        details = "Nothing added yet"
                        date_str = (
                            date.strftime("%d-%m-%y %H:%M:%S")
                            if date
                            else "Unknown Date"
                        )
                        processing_state = "PROCESSED"

                        # Append the result
                        results.append(
                            {
                                "File Name": file.split("_")[1],
                                "Processing State": processing_state,
                                "Status for average values": status,
                                "Average": avg,
                                "Variance": var,
                                "Status for max values": status_max,
                                "Maximum": max_val,
                                "Date": date_str,
                                "Details": details,
                            }
                        )

                    file_count += 1  # Increment the counter
                    if file_limit != None:
                        if file_count >= file_limit:
                            break  # Stop processing after reaching the limit

            if file_limit != None:
                if file_count >= file_limit:
                    break  # Stop outer loop if limit is reached

        return results
    except Exception as e:
        tb = traceback.format_exc()
        failed_function_name = traceback.extract_tb(sys.exc_info()[2])[-1].name
        logging.info(f"Error in function '{failed_function_name}': {e}")
        logging.info(f"Traceback: {tb}")
        return None


def process_fif_file(file_path):
    s_avg = 3
    s_max = 10
    s_fft = 10

    # Load raw MEG/EEG data from a .fif file
    raw = mne.io.read_raw_fif(file_path, preload=False)

    data_duration = raw.times[-1]

    if TMAX <= data_duration and TMIN <= data_duration:
        # Crop data:
        raw = raw.crop(TMIN, TMAX)
        logging.info(f"Cropped data for: {file_path}")

    # Select channels that start with 'L' or 'R'
    selected_channels = [
        ch_name for ch_name in raw.ch_names if ch_name.startswith(("L", "R"))
    ]

    # Pick only those channels
    raw.pick(selected_channels)

    # Optional: Remove zero channels (if needed)
    raw = remove_zero_channels(raw)

    # Get data and calculate statistics
    data = raw.get_data()  # Get data from the selected channels
    avg = np.mean(data, axis=1)  # Average over time (axis=1)
    var = np.var(data, axis=1)  # Variance over time (axis=1)
    max_val = np.max(data, axis=1)  # Maximum value over time (axis=1)

    # FFT calculation
    sfreq = raw.info["sfreq"]
    freqs, fft_data = compute_fft(data, sfreq)

    # Status for avg
    status_avg = [
        ("🟢 In the threshold" if np.all(avg < s_avg) else "🔴 Above the threshold")
    ]

    # Status for fft
    status_fft = [
        (
            "🟢 In the threshold"
            if np.all(fft_data < s_fft)
            else "🔴 Above the threshold"
        )
    ]

    # Status for max
    status_max = [
        ("🟢 In the threshold" if np.all(max_val < s_max) else "🔴 Above the threshold")
    ]

    # Return the processed values
    return avg, var, max_val, status_avg, freqs, fft_data, status_fft, status_max


def process_all_fif_files(base_folder, file_limit=None):
    """Process all .fif files in a base folder up to a file limit."""
    results = []
    file_count = 0  # Initialize a counter

    try:
        for root, _, files in os.walk(base_folder):
            for file in files:
                if file.endswith(".fif"):
                    file_path = os.path.join(root, file)

                    result = process_fif_file(file_path)

                    processing_state = "UNPROCESSED"

                    if result is None:
                        logging.info(f"Processing failed for {file_path}")
                    else:
                        # Process the file
                        (
                            avg,
                            var,
                            max_val,
                            status_avg,
                            freqs,
                            fft_data,
                            status_fft,
                            status_max,
                        ) = result

                        # Extract date (assuming filename contains a date in the expected format)
                        date = extract_date(file)
                        details = "Nothing added yet"
                        date_str = (
                            date.strftime("%d-%m-%y %H:%M:%S")
                            if date
                            else "Unknown Date"
                        )

                        processing_state = "PROCESSED"

                        # Append the result
                        results.append(
                            {
                                "File Name": file,
                                "Processing State": processing_state,
                                "Status for average values": status_avg,
                                "Average": avg.tolist(),
                                "Variance": var.tolist(),
                                "Status for max values": status_max,
                                "Maximum": max_val.tolist(),
                                "Date": date_str,
                                "Details": details,
                            }
                        )

                    file_count += 1  # Increment the counter
                    if file_limit is not None and file_count >= file_limit:
                        break  # Stop processing after reaching the limit

            if file_limit is not None and file_count >= file_limit:
                break  # Stop outer loop if limit is reached

        return results
    except Exception as e:
        tb = traceback.format_exc()
        failed_function_name = traceback.extract_tb(sys.exc_info()[2])[-1].name
        logging.info(f"Error in function '{failed_function_name}': {e}")
        logging.info(f"Traceback: {tb}")
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
        logging.info(f"Error in function '{failed_function_name}': {e}")
        logging.info(f"Traceback: {tb}")


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
        logging.info(f"Plot saved to {output_html}")
    except Exception as e:
        logging.info(f"Error processing: {e}")


def remove_zero_channels(raw):
    data = raw.get_data()
    non_zero_indices = np.any(data != 0, axis=1)
    # print(non_zero_indices)
    raw.pick(
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
    logging.info(f"Plot saved to {output_html}")


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
    logging.info(f"Plot saved to {output_html}")


def compute_fft(data, sfreq):
    fft_data = np.fft.rfft(data, axis=-1)
    freqs = np.fft.rfftfreq(data.shape[-1], d=1 / sfreq)
    return freqs, np.abs(fft_data)


#### Main begin #####

logging.basicConfig(level=logging.INFO)

try:

    PROCESSKIT = True
    PROCESSOPM = True

    KIT_FILE_LIMIT = 2
    OPM_FILE_LIMIT = None

    TMIN = 10.0
    TMAX = 60.0

    #KIT .con metric computation
    if PROCESSKIT:
        # Set the base folder containing .con files and subfolders
        base_folder = r"data"
        # Set the output CSV file path
        output_file = "9-dashboard/data/data-quality-dashboards/kit-con-files-statistics.csv"

        # Process all .con files and save the results
        results = process_all_con_files(base_folder, file_limit=KIT_FILE_LIMIT)
        save_results_to_csv(results, output_file)

        logging.info(f"Results saved to {output_file}")
        # print(results)

        csv_file = output_file  # Path to the CSV file
        output_avg_html = "_static/2-data-quality-dashboards/kit_average_plot.html"  # Path to save the HTML file

        # Ensure output directory exists
        os.makedirs(os.path.dirname(output_avg_html), exist_ok=True)

        # Create and save the plot
        plot_data_avg(csv_file, output_avg_html)

        output_variance_html = "_static/2-data-quality-dashboards/kit_variance_plot.html"  # Path to save the HTML file

        # Ensure output directory exists
        os.makedirs(os.path.dirname(output_variance_html), exist_ok=True)

        # Create and save the plot
        plot_data_var(csv_file, output_variance_html)
        output_variance_html = "_static/2-data-quality-dashboards/kit_max_plot.html"
        plot_data_max(csv_file, output_variance_html)


    if PROCESSOPM:
        # OPM .fif metric computation

        # Set the base folder containing .con files and subfolders
        base_folder = r"data/meg-opm"
        # Set the output CSV file path
        output_file = "9-dashboard/data/data-quality-dashboards/opm-fif-files-statistics.csv"
        # Process all .con files and save the results
        results = process_all_fif_files(base_folder, file_limit=OPM_FILE_LIMIT)
        save_results_to_csv(results, output_file)

        logging.info(f"Results saved to {output_file}")
        # print(results)

        csv_file = output_file  # Path to the CSV file
        output_avg_html = (
            "_static/2-data-quality-dashboards/opm_average_plot.html"  # Path to save the HTML file
        )

        # Ensure output directory exists
        os.makedirs(os.path.dirname(output_avg_html), exist_ok=True)

        # Create and save the plot
        plot_data_avg(csv_file, output_avg_html)

        output_variance_html = (
            "_static/2-data-quality-dashboards/opm_variance_plot.html"  # Path to save the HTML file
        )

        # Ensure output directory exists
        os.makedirs(os.path.dirname(output_variance_html), exist_ok=True)

        # Create and save the plot
        plot_data_var(csv_file, output_variance_html)
        output_variance_html = "_static/2-data-quality-dashboards/opm_max_plot.html"
        plot_data_max(csv_file, output_variance_html)


    # Display memory usage
    current, peak = tracemalloc.get_traced_memory()
    print(f"Current memory usage: {current / 1024 / 1024:.2f} MB")
    print(f"Peak memory usage: {peak / 1024 / 1024:.2f} MB")

    # Stop the trace
    tracemalloc.stop()


except:
    logging.info(f"Error processing")
########################################################################
"""
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
"""
################################################################################
"""
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
output_file = r"_static/average_plot_opm_data.html"
# process_fifo_files(base_folder, output_file)
"""
