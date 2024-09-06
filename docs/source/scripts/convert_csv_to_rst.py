import os
import csv
import plotly.graph_objects as go
import pandas as pd
from datetime import datetime

def read_csv(file_path):
    """Read a CSV file and return its content as a list of rows."""
    with open(file_path, newline="") as csvfile:
        reader = csv.reader(csvfile)
        table_data = [row for row in reader]
    return table_data


def convert_csv_to_rst(csv_file, rst_file):
    """Convert a CSV file to reStructuredText format."""
    table_data = read_csv(csv_file)
    with open(rst_file, "w") as file:
        file.write(
            ".. list-table:: Metrics for assessing data quality (Noise levels)\n"
        )
        file.write("   :header-rows: 1\n\n")
        for row in table_data:
            file.write("   * - " + "\n     - ".join(row) + "\n")


def convert_all_csvs_to_rst(base_folder, output_folder):
    """Convert all CSV files in a directory to reStructuredText format and save them in the output folder."""
    os.makedirs(output_folder, exist_ok=True)  # Ensure the output directory exists

    for root, _, files in os.walk(base_folder):
        for file in files:
            if file.endswith(".csv"):
                csv_file_path = os.path.join(root, file)
                # Construct the path for the .rst file in the output folder
                rst_file_name = os.path.splitext(file)[0] + ".rst"
                rst_file_path = os.path.join(output_folder, rst_file_name)
                convert_csv_to_rst(csv_file_path, rst_file_path)
                print(f"Converted {csv_file_path} to {rst_file_path}")


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


if __name__ == "__main__":
    # Set the base folder containing CSV files
    # base_folder = os.path.abspath(
    #     os.path.join(os.path.dirname(__file__), "../9-dashboard/data")
    # )
    base_folder = "9-dashboard/data"

    # Set the output folder where .rst files will be saved

    output_folder = "9-dashboard"

    # output_folder = os.path.abspath(
    #     os.path.join(os.path.dirname(__file__), "../9-dashboard")
    # )

    # Convert all CSV files in the base folder to RST format and save them in the output folder
    convert_all_csvs_to_rst(base_folder, output_folder)

    #Generate the Plot html files

    #output_file = r"docs/source/9-dashboard/data/con_files_statistics.csv"

    output_file = "9-dashboard/data/con_files_statistics.csv"

    csv_file = output_file  # Path to the CSV file

    output_html = "_static/average_variance_plot.html"

    # output_html = (
    #     r"docs/source/_static/average_variance_plot.html"  # Path to save the HTML file
    # )

    # Ensure output directory exists
    os.makedirs(os.path.dirname(output_html), exist_ok=True)

    # Create and save the plot
    plot_data(csv_file, output_html)
