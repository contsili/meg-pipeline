import os
import numpy as np
import pandas as pd
import mne
import re
from datetime import datetime
import plotly.graph_objects as go


def process_con_file(file_path):
    # Load the .con file using MNE
    raw = mne.io.read_raw_kit(file_path, preload=True)

    # Get data for all channels
    data, times = raw[:, :]

    # Calculate average and variance across all channels
    avg = np.mean(data)
    var = np.var(data)

    return avg, var


def process_all_con_files(base_folder):
    results = []

    for root, _, files in os.walk(base_folder):
        for file in files:
            if file.endswith(".con"):
                file_path = os.path.join(root, file)
                avg, var = process_con_file(file_path)
                date = extract_date(file)
                date_str = date.strftime("%Y-%m-%d") if date else "Unknown Date"
                results.append(
                    {
                        "File Name": file,
                        "Average": avg,
                        "Variance": var,
                        "Date": date_str,
                    }
                )

    return results


def save_results_to_csv(results, output_file):
    # Ensure the directory exists
    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    # Save results to CSV
    df = pd.DataFrame(results)
    df.to_csv(output_file, index=False)


def extract_date(filename):
    # Patterns to match different date formats
    patterns = [
        r"(\d{2})_(\w+)_(\d{4})",  # Format: 28_June_2024
        r"(\d{4})-(\d{2})-(\d{2})",  # Format: 2013-08-14
        r"(\d{2})-(\d{2})-(\d{2})",  # Format: 03-04-05 (example for demonstration)
    ]
    for pattern in patterns:
        match = re.search(pattern, filename)
        if match:
            try:
                if len(match.groups()) == 3:
                    if pattern == r"(\d{2})_(\w+)_(\d{4})":
                        # Format: 28_June_2024
                        day, month, year = match.groups()
                        date_str = f"{day} {month} {year}"
                    else:
                        # Format: 2013-08-14 or 03-04-05
                        year, month, day = match.groups()
                        date_str = f"{year}-{month}-{day}"
                    return (
                        datetime.strptime(date_str, "%d %B %Y")
                        if pattern == r"(\d{2})_(\w+)_(\d{4})"
                        else datetime.strptime(date_str, "%Y-%m-%d")
                    )
            except ValueError:
                continue
    return None


def plot_data(csv_file, output_html):
    # Load data from CSV
    df = pd.read_csv(csv_file)

    # Ensure 'Date' column is in datetime format
    df["Date"] = pd.to_datetime(df["Date"], errors="coerce")
    df = df.sort_values(by="Date")

    # Create figure
    fig = go.Figure()

    # Add line plot for Average
    fig.add_trace(
        go.Scatter(
            x=df["Date"],
            y=df["Average"],
            mode="lines+markers",
            line=dict(color="blue"),
            marker=dict(color="blue", size=8),
            name="Average",
        )
    )

    # Add line plot for Variance
    fig.add_trace(
        go.Scatter(
            x=df["Date"],
            y=df["Variance"],
            mode="lines+markers",
            line=dict(color="grey"),
            marker=dict(color="grey", size=8),
            name="Variance",
        )
    )

    # Update layout
    fig.update_layout(
        title="Average and Variance Over Time",
        xaxis_title="Date",
        yaxis_title="Value",
        legend_title="Metrics",
    )

    # Save plot as HTML
    fig.write_html(output_html)
    print(f"Plot saved to {output_html}")


# Set the base folder containing .con files and subfolders
base_folder = r"data"
# Set the output CSV file path
output_file = r"docs/source/9-dashboard/data/con_files_statistics.csv"

# Process all .con files and save the results
results = process_all_con_files(base_folder)
save_results_to_csv(results, output_file)

print(f"Results saved to {output_file}")

csv_file = output_file  # Path to the CSV file
output_html = (
    r"docs/source/_static/average_variance_plot.html"  # Path to save the HTML file
)

# Ensure output directory exists
os.makedirs(os.path.dirname(output_html), exist_ok=True)

# Create and save the plot
plot_data(csv_file, output_html)
