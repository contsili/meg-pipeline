Data Quality Dashboards
#######################

An MEG signal is a tiny magnetic fields, in the order of 100 fT, where
femtotesla  :math:`1fT = 10^{-15} T` and picotesla :math:`1pT = 10^{-12} T`.

EEG scalp signals are about 50 to 100 :math:`\mu\text{V}`


Several metrics are defined in the below table and will serve as basis to asess the quality of data.

.. include:: noise_metrics.rst

.. include:: con_files_statistics.rst

.. include:: KIT_data_quality_dashboard.rst

Plot of Average and Variance Over Time
######################################

.. raw:: html

    <iframe src="../_static/average_plot.html" width="100%" height="600px" frameborder="0"></iframe>
    <iframe src="../_static/variance_plot.html" width="100%" height="600px" frameborder="0"></iframe>

.. include:: OPM_data_quality_dashboard.rst

Documentation for the following dashboard
##########################################

This dashboard's objective is to monitor the quality of the empty-room data with informative labels, for quick acess and over all numerical values in a simple format.
It has graphs showing the average and variance of each empty-room data file, as well as one table listing the current state of each empty-room data file.

1. The source of this data is the files generated from each experiment, hosted on the NYU-BOX data drive. This process is done by a python script that authontificats on BOX-DATA, downloads all the '.con' files that exists inside the empty-room while also getting the date they were last modified. 


2. Overview of the table:


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


3. Use cases:

   - Easly monitor the status using table
   - Get the average of each room data with variance.

Dashboard generation developper guide
#####################################

The dashboard is generated from empty room data hosted on NYU-BOX storage drive.
The scripts generating the dashboard are under `docs/source/9-dashboard/dashboard-generating-scripts`

- `box_script.py` connects to NYU BOX and downloads empty room data to the build server by entering the private keys as either .env file in your machine or as environment variable in your build. This step will differ depending on your needs so it's important to add error handlers.


First, you need to install the boxsdk library:


.. code-block:: python
   pip install boxsdk


DEfine your privet keys like the client_id, client_secret and any other keys. Then, set up the JWT authentication:


.. code-block:: python
  auth = JWTAuth(
        client_id=client_id,
        client_secret=client_secret,
        jwt_key_id=public_key_id,
    )
  client = Client(auth)

After you access the Box-DATA correctly, you will need to create a function that gets the ID of the folders (unique address for each folder): Given a path, it starts at the root directory,the path is a list of folder names separated by a "/". It starts with the root folder ID and goes through each folder name in the path one by one. If it finds a folder with the right name, it updates the folder_id to that folder's ID, and then it moves into that folder to keep searching.


.. code-block:: python
   def get_folder_id_by_path(path):
   #root folder id is 0
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

Then a function that downloads the files in a directory that you define.


.. code-block:: python
    def download_con_files_from_folder(folder_id, path):
        folder = client.folder(folder_id).get()
        items = folder.get_items(limit=100, offset=0)

        for item in items:
                if item.type == "file" and item.name.endswith(".con"):
                    file_id = item.id
                    file = client.file(file_id).get()
                    filename = f"{file.name}"
                    file_path = f"{path}/{filename}"
                    file_path = os.path.join(path, filename)
                        with open(file_path, "wb") as open_file:
                            file.download_to(open_file)
                elif item.type == "folder":
                    new_folder_path = os.path.join(path, item.name)
                    os.makedirs(new_folder_path, exist_ok=True)
                    download_con_files_from_folder(item.id, new_folder_path, last_date)


If you would like to get the date, it was last modified  just add " file.modified_at"


- `processing_con_files_for_table.py` process the .con files, compute the metrics and generates a .csv file with the results. The script will process all the .con files, each one calculating the average of it's signal and the variance. It gets the date and determines whether or not it is in the threshold. It creates a .csv file with the results, and graphs to display the numerical values.


- `convert_csv_to_rst.py` generates rst pages from the csv files

