# This file will be updated to contain the script to generate the dashboard
# the script to automate its update is conf.py

import plotly.graph_objs as go
import plotly.io as pio

# Sample data
x = [1, 2, 3, 4, 5, 6, 7, 8]
y = [10, 14, 12, 20, 18, 20, 22, 23]

# Create a scatter plot
fig = go.Figure(data=go.Scatter(x=x, y=y, mode="lines+markers"))

# Save the figure as an HTML file
pio.write_html(fig, file="_static/plotly_dashboard.html", auto_open=False)


################################################################################################
import os

# Data for the table
status = ["Active", "Inactive", "Active", "Inactive"]
system_name = ["System A", "System B", "System C", "System D"]

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
                values=[status, system_name], fill_color="lavender", align="left"
            ),
        )
    ]
)

# Update layout
fig.update_layout(title="System Status Dashboard", width=500, height=300)

# Ensure the directory exists
output_dir = os.path.abspath(os.path.join("..", "docs", "source", "_static"))
os.makedirs(output_dir, exist_ok=True)

# Define the output file path
output_file = os.path.join(output_dir, "plotly_dashboard02.html")

# Save the figure as an HTML file
pio.write_html(fig, output_file)
