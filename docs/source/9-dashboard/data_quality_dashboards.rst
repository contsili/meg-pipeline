Data Quality Dashboards
#######################

An MEG signal is a tiny magnetic fields, in the order of 100 fT, where
femtotesla  :math:`1fT = 10^{-15} T` and picotesla :math:`1pT = 10^{-12} T`.

EEG scalp signals are about 50 to 100 :math:`\mu\text{V}`


Several metrics are defined in the below table and will serve as basis to asess the quality of data.

.. include:: noise_metrics.rst

.. include:: con_files_statistics.rst

.. include:: KIT_data_quality_dashboard.rst

*Plot of Average and Variance Over Time*


.. raw:: html

    <iframe src="../_static/average_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/variance_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/fft_plots_combined.html" width="100%" height="600px" frameborder="0"></iframe>
    

.. include:: OPM_data_quality_dashboard.rst

Documentation for the following dashboard
##########################################

This dashboard's objective is to monitor the quality of the empty-room data with informative labels, for quick access and over all numerical values in a simple format.
It has graphs showing the average and variance of each empty-room data file, as well as one table listing the current state of each empty-room data file.

*1.* The source of this data is the files generated from each experiment, hosted on the NYU-BOX data drive. This process is done by a Python script that authenticates on BOX-DATA, downloads all the '.con' files that exists inside the empty-room while also getting the date they were last modified. 


*2.* Overview of the table:


  .. list-table:: File Details
   :header-rows: 1
   :widths: 15 50 35

   * - Column Name
     - Description
     - Obtained
   * - Status
     - Gives the status of the given file's average if it's above or within the threshold. The status is indicated by a color: green for safe, red for above the threshold. The threshold is defined as below 3 fT.
     - Calculates the average of the signal over time and compares it to the threshold.
   * - File Name
     - It is a combination of the time and the name of the file, separated by a '_'.
     - Obtained from the metadata available in the NYU-DATA box.
   * - Average
     - Calculates the average of the signal over time.
     - Calculated by the simple functions defining the average function in Python.
   * - Variance
     - Calculates the variance of the signal over time.
     - Calculated by the simple functions defining the variance function in Python.
   * - Date
     - The date is defined as: format="%d-%m-%y %H:%M:%S".
     - Obtained from the metadata of the 'last-modified' field.
   * - Details
     - Describes the details of the day and/or experiment that might explain the results obtained in the file.
     - Added by the user, default is "Nothing added yet".


*3.* Use cases:

   - Easily monitor the status using the table
   - Get the average of each room's data with variance.

Dashboard Generation Developer Guide
####################################

*Overview*

The dashboard is generated from empty room data hosted on the NYU-BOX storage drive. The scripts for generating the dashboard are located under `docs/source/9-dashboard/dashboard-generating-scripts`.

This guide explains how to download empty room data from the NYU-BOX storage using Python scripts. It covers setting up the Box SDK, authenticating using JWT, accessing folder data, and downloading `.con` files. It also includes information on processing these downloaded files.

- `box_script.py` connects to NYU-BOX and downloads empty room data to the build server. It uses private keys, which can be provided as an `.env` file on your machine or set as environment variables in your build. This step will vary depending on your setup, so it's important to include error handling.

*Installation*

First, you need to install the `boxsdk` library. If you are using a `.env` file, you will also need to install `python-dotenv`:

.. code-block:: bash

   pip install boxsdk
   pip install python-dotenv

*Setting Up Authentication*

Define your private keys, such as `client_id`, `client_secret`, and any other necessary keys. Then, set up JWT authentication:

.. code-block:: python

   from boxsdk import JWTAuth, Client

   auth = JWTAuth(
       client_id=client_id,
       client_secret=client_secret,
       jwt_key_id=public_key_id,
       # Add any additional keys needed
   )
   client = Client(auth)

*Accessing Folders*

After accessing the Box data correctly, you need to create a function that retrieves the ID of folders (the unique address for each folder). This function will start at the root directory and traverse the path, which is a list of folder names separated by "/". It begins with the root folder ID and checks each folder name in the path. If it finds a folder with the matching name, it updates the `folder_id` to that folder's ID and continues to the next folder:

.. code-block:: python

   def get_folder_id_by_path(path):
       # Root folder id is "0"
       folder_id = "0" 
       for folder_name in path.split("/"):
           items = client.folder(folder_id).get_items()
           folder_id = None
           for item in items:
               if item.type == "folder" and item.name == folder_name:
                   folder_id = item.id
                   break
           if folder_id is None:
               raise ValueError(f'Folder "{folder_name}" not found in path.')
       return folder_id

*Downloading Files*

Next, create a function that downloads files from a specified directory. This function will download all `.con` files, and if it finds a folder, it will call the function again recursively:

.. code-block:: python

   import os

   def download_con_files_from_folder(folder_id, path):
       folder = client.folder(folder_id).get()
       items = folder.get_items(limit=100, offset=0)

       for item in items:
           # Define the type of file you want to download
           if item.type == "file" and item.name.endswith(".con"):
               file_id = item.id
               file = client.file(file_id).get()
               filename = f"{file.name}"
               file_path = os.path.join(path, filename)
               with open(file_path, "wb") as open_file:
                   file.download_to(open_file)
           elif item.type == "folder":
               new_folder_path = os.path.join(path, item.name)
               os.makedirs(new_folder_path, exist_ok=True)
               download_con_files_from_folder(item.id, new_folder_path)

To get the date when a file was last modified, you can use `file.modified_at`.

*Data Preparation*

- `processing_con_files_for_table.py` processes the `.con` files, computes metrics, and generates a `.csv` file with the results.

.. code-block:: python

    import os
    import numpy as np
    import pandas as pd
    import mne

    def process_all_con_files(base_folder):
        results = []

        for root, _, files in os.walk(base_folder):
            for file in files:
                if file.endswith(".con"):
                    file_path = os.path.join(root, file)
                    # Get the results of the function that calculates the average, variance, and status
                    avg, var, status = process_con_file(file_path)
                    # A function that extracts the date
                    date = extract_date(file)
                    # Default value for details
                    details = "Nothing added yet"
                    # Format the date string to your needs
                    date_str = (
                        date.strftime("%d-%m-%y %H:%M:%S") if date else "Unknown Date"
                    )
                    results.append(
                        {
                            "Status": status,
                            "File Name": file,
                            "Average": avg,
                            "Variance": var,
                            "Date": date_str,
                            "Details": details,
                        }
                    )

        return results

This script processes all `.con` files, calculating the average and variance of each signal. It also checks the date to see if it falls within a specified threshold.

.. code-block:: python

    def process_con_file(file_path):
        # Load the .con file using MNE
        threshold = 3  # Set the threshold
        raw = mne.io.read_raw_kit(file_path, preload=True)
        raw.pick_types(meg=True, eeg=False)

        # Get data for all channels
        data, times = raw.get_data(return_times=True)
        # Calculate average and variance across all channels
        avg = (np.mean(data)) * 1e15  # Convert to femtotesla
        var = np.var(data)
        status = [
            f"🟢 In the threshold" if avg < threshold else f"🔴 Above the threshold"
        ]

        return avg, var, status

The script generates a `.csv` file with the results and creates graphs to display the numerical values.

.. code-block:: python

    def save_results_to_csv(results, output_file):
        # Ensure the directory exists
        os.makedirs(os.path.dirname(output_file), exist_ok=True)

        # Save results to CSV
        df = pd.DataFrame(results)
        df.to_csv(output_file, index=False)

- `convert_csv_to_rst.py` generates `.rst` pages from the CSV files. It accesses all the `.csv` files in a specific directory, converts them into reStructuredText format, and saves them in the output folder.
