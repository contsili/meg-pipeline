"""
Authors: Emna Tayachi, Hadi Zaatiti

Authentication with BOX to access and download empty-room KIT and OPM data.
"""

import os
from boxsdk import JWTAuth, Client
from boxsdk.exception import BoxAPIException
from dotenv import load_dotenv
from boxsdk.object.folder import Folder
import pandas as pd
from datetime import datetime
import pytz
import logging
import traceback


EMPTY_ROOM_DATA_PATH = "Data/empty-room/sub-emptyroom"

KIT_EMPTY_ROOM_DATA_PATH = EMPTY_ROOM_DATA_PATH+"/meg-kit"
OPM_EMPTY_ROOM_DATA_PATH = EMPTY_ROOM_DATA_PATH+"/meg-opm"

KIT_CSV_PATH = "9-dashboard/data/data-quality-dashboards/kit-con-files-statistics.csv"
OPM_CSV_PATH = "9-dashboard/data/data-quality-dashboards/opm-fif-files-statistics.csv"

KIT_CON_FILE_DOWNLOAD_LIMIT = 2
OPM_FIF_FILE_DOWNLOAD_LIMIT = 2

def upload_file(folder_path):
    # Locate the target folder
    try:
        folder_id = get_folder_id_by_path(folder_path)
    except ValueError as e:
        print(e)
        return

    # Upload a file to the target folder
    file_path = "test.txt"
    try:
        with open(file_path, "rb") as file_stream:
            uploaded_file = client.folder(folder_id).upload_stream(
                file_stream, "file.txt"
            )
            print(
                f'File "{uploaded_file.name}" uploaded to Box with file ID {uploaded_file.id}'
            )
    except BoxAPIException as e:
        print(f"Error uploading file: {e}")
        traceback.print_exc()
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        traceback.print_exc()


def get_folder_id_by_path(path):
    folder_id = "0"  # Start with the root folder
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





def download_empty_room_data_from_folder(folder_id, path, last_date, kit_con_files_download_counter=0, opm_fif_files_download_counter=0):
    try:
        folder = client.folder(folder_id).get()
        items = folder.get_items(limit=10000, offset=0)

        kit_df = pd.read_csv(KIT_CSV_PATH)
        opm_df = pd.read_csv(OPM_CSV_PATH)

        for item in items:
            try:
                if item.type == "file":

                    file_id = item.id
                    file = client.file(file_id).get()

                    # Get the content creation date
                    created_at = datetime.strptime(
                        file.content_created_at, "%Y-%m-%dT%H:%M:%S%z"
                    )

                    #formatted_date = created_at.strftime("%d-%m-%y-%H-%M-%S")
                    #filename = f"{formatted_date}_{file.name}"

                    filename = file.name
                    file_path = os.path.join(path, filename)

                    if item.name.endswith((".con")):
                        if (filename not in kit_df['File Name']
                                and kit_con_files_download_counter<KIT_CON_FILE_DOWNLOAD_LIMIT):

                            new_row = pd.DataFrame({'File Name': filename,
                                                    'Processing State': ['TO BE PROCESSED']})

                            kit_df = pd.concat([kit_df, new_row], ignore_index=True)

                            # Open the .csv files

                            # Download the file
                            with open(file_path, "wb") as open_file:
                                file.download_to(open_file)

                            kit_df.to_csv(KIT_CSV_PATH, index=False)

                            kit_con_files_download_counter +=1

                            logging.info(f"Downloaded KIT File {filename} to {file_path}")

                        else:
                            logging.info(f"File {filename} already processed")

                    elif item.name.endswith((".fif")):

                        if (filename not in opm_df['File Name']
                                and opm_fif_files_download_counter<OPM_FIF_FILE_DOWNLOAD_LIMIT):



                            new_row = pd.DataFrame({'File Name': filename,
                                                    'Processing State': ['TO BE PROCESSED']})

                            opm_df = pd.concat([opm_df, new_row], ignore_index=True)


                            # Open the .csv files

                            # Download the file
                            with open(file_path, "wb") as open_file:
                                file.download_to(open_file)

                            opm_df.to_csv(OPM_CSV_PATH, index=False)

                            opm_fif_files_download_counter+=1

                            logging.info(f"Downloaded OPM FILE {filename} to {file_path}")
                        else:
                            logging.info(f"File {filename} already processed")

                elif item.type == "folder":
                    new_folder_path = os.path.join(path, item.name)
                    os.makedirs(new_folder_path, exist_ok=True)
                    download_empty_room_data_from_folder(item.id, new_folder_path, last_date, kit_con_files_download_counter, opm_fif_files_download_counter)



            except Exception as e:
                logging.error(
                    f"Failed to download file or process folder '{item.name}': {str(e)}"
                )
                logging.info(f"Error processing item '{item.name}': {str(e)}")
                traceback.print_exc()

        return kit_con_files_download_counter, opm_fif_files_download_counter

    except Exception as e:
        logging.error(f"Failed to access folder with ID {folder_id}: {str(e)}")
        print(f"Error accessing folder with ID {folder_id}: {str(e)}")
        traceback.print_exc()



def download_kit_empty_room_data_from_folder(folder_id, path):
    try:
        folder = client.folder(folder_id).get()
        items = folder.get_items(limit=10000, offset=0)

        kit_df = pd.read_csv(KIT_CSV_PATH)

        kit_con_files_download_counter = 0

        for item in items:
            try:

                if item.type == "file" and item.name.endswith((".con")):

                    if kit_con_files_download_counter >= KIT_CON_FILE_DOWNLOAD_LIMIT:
                        logging.info("Download Limit for KIT reached")
                        break

                    else:

                        file_id = item.id
                        file = client.file(file_id).get()

                        # Get the content creation date
                        created_at = datetime.strptime(
                            file.content_created_at, "%Y-%m-%dT%H:%M:%S%z"
                        )

                        #formatted_date = created_at.strftime("%d-%m-%y-%H-%M-%S")
                        #filename = f"{formatted_date}_{file.name}"

                        filename = file.name
                        file_path = os.path.join(path, filename)

                        if (filename not in kit_df['File Name'].values):

                            new_row = pd.DataFrame({'File Name': filename,
                                                    'Processing State': ['TO BE PROCESSED']})

                            kit_df = pd.concat([kit_df, new_row], ignore_index=True)

                            # Open the .csv files

                            # Download the file
                            with open(file_path, "wb") as open_file:
                                file.download_to(open_file)

                            kit_df.to_csv(KIT_CSV_PATH, index=False)

                            kit_con_files_download_counter +=1

                            logging.info(f"Downloaded KIT File {filename} to {file_path}")

                        else:
                            logging.info(f"File {filename} already processed")

            except Exception as e:
                logging.error(
                    f"Failed to download file or process folder '{item.name}': {str(e)}"
                )
                logging.info(f"Error processing item '{item.name}': {str(e)}")
                traceback.print_exc()

        logging.info(f"Downloaded {kit_con_files_download_counter} KIT files")

    except Exception as e:
        logging.error(f"Failed to access folder with ID {folder_id}: {str(e)}")
        print(f"Error accessing folder with ID {folder_id}: {str(e)}")
        traceback.print_exc()

def download_opm_empty_room_data_from_folder(folder_id, path):
    try:
        folder = client.folder(folder_id).get()
        items = folder.get_items(limit=10000, offset=0)

        opm_df = pd.read_csv(OPM_CSV_PATH)

        opm_fif_files_download_counter = 0

        for item in items:
            try:

                if item.type == "file" and item.name.endswith((".fif")):

                    if opm_fif_files_download_counter >= OPM_FIF_FILE_DOWNLOAD_LIMIT:
                        logging.info("Download Limit for OPM reached")
                        break

                    else:

                        file_id = item.id
                        file = client.file(file_id).get()

                        # Get the content creation date
                        created_at = datetime.strptime(
                            file.content_created_at, "%Y-%m-%dT%H:%M:%S%z"
                        )

                        #formatted_date = created_at.strftime("%d-%m-%y-%H-%M-%S")
                        #filename = f"{formatted_date}_{file.name}"

                        filename = file.name
                        file_path = os.path.join(path, filename)

                        if (filename not in opm_df['File Name'].values):

                            new_row = pd.DataFrame({'File Name': filename,
                                                    'Processing State': ['TO BE PROCESSED']})

                            opm_df = pd.concat([opm_df, new_row], ignore_index=True)

                            # Open the .csv files

                            # Download the file
                            with open(file_path, "wb") as open_file:
                                file.download_to(open_file)

                            opm_df.to_csv(OPM_CSV_PATH, index=False)

                            opm_fif_files_download_counter +=1

                            logging.info(f"Downloaded OPM File {filename} to {file_path}")

                        else:
                            logging.info(f"File {filename} already processed")

            except Exception as e:
                logging.error(
                    f"Failed to download file or process folder '{item.name}': {str(e)}"
                )
                logging.info(f"Error processing item '{item.name}': {str(e)}")
                traceback.print_exc()

        logging.info(f"Downloaded {opm_fif_files_download_counter} OPM files")

    except Exception as e:
        logging.error(f"Failed to access folder with ID {folder_id}: {str(e)}")
        print(f"Error accessing folder with ID {folder_id}: {str(e)}")
        traceback.print_exc()

def get_folder():
    try:
        items = client.folder("0").get_items()
        print("Contents of the root folder:")
        for item in items:
            print(f"Item: {item.name} (ID: {item.id})")
    except BoxAPIException as e:
        print(f"Error fetching folder contents: {e}")
        traceback.print_exc()


def download_file(file_path, download_path):
    path_parts = file_path.split("/")
    file_name = path_parts[-1]
    folder_path = "/".join(path_parts[:-1])

    # Locate the target folder
    try:
        folder_id = get_folder_id_by_path(folder_path)
    except ValueError as e:
        print(e)
        return

    # Find the file in the target folder
    try:
        items = client.folder(folder_id).get_items()
        file_id = None
        for item in items:
            if item.type == "file" and item.name == file_name:
                file_id = item.id
                break
        if not file_id:
            print(f'File "{file_name}" not found in folder "{folder_path}".')
            return

        # Download the file
        with open(download_path, "wb") as file_stream:
            client.file(file_id).download_to(file_stream)
        print(f'File "{file_name}" downloaded to {download_path}.')
    except BoxAPIException as e:
        print(f"Error downloading file: {e}")
        traceback.print_exc()


# Set the logging level for the boxsdk to WARNING or ERROR
logging.getLogger("boxsdk").setLevel(logging.WARNING)

logging.basicConfig(level=logging.INFO)

# Check if the file exists
if os.path.exists("box_secrets.env"):
    load_dotenv("box_secrets.env")
else:
    logging.info("box_secrets.env file not found. Skipping load.")

# Try to auth else exit box-script
try:

    # Load the configuration from environment variables
    client_id = os.getenv("BOX_CLIENT_ID")
    # logging.info(f"Client ID {client_id}")
    client_secret = os.getenv("BOX_CLIENT_SECRET")
    # print(client_secret)
    enterprise_id = os.getenv("BOX_ENTERPRISE_ID")
    # print(enterprise_id)
    public_key_id = os.getenv("BOX_PUBLIC_KEY_ID")
    # print(public_key_id)

    private_key = os.getenv("BOX_PRIVATE_KEY")

    # Ensure it's correctly formatted (remove extra quotes if they exist) This caused an issue on the RTD scripts
    if private_key.startswith("'") and private_key.endswith("'"):
        private_key = private_key[1:-1]

    # Replace escaped newlines with actual newlines
    private_key = private_key.replace("\\n", "\n").encode()

    passphrase = os.getenv("BOX_PASSPHRASE").encode()

    if all(
        [
            client_id,
            client_secret,
            enterprise_id,
            public_key_id,
            private_key,
            passphrase,
        ]
    ):
        logging.info("Secrets retrieved successfully.")
    else:
        logging.error("Secrets not retrieved.")

    # Set up JWT authentication
    auth = JWTAuth(
        client_id=client_id,
        client_secret=client_secret,
        enterprise_id=enterprise_id,
        jwt_key_id=public_key_id,
        rsa_private_key_data=private_key,
        rsa_private_key_passphrase=passphrase,
    )

    # Authenticate and create a client
    auth.authenticate_instance()
    client = Client(auth)

    # Example: Get the details of the current user
    try:
        user = client.user().get()
        logging.info(f"User ID: {user.id}")
        logging.info(f"User Login: {user.login}")
    except BoxAPIException as e:
        logging.info(f"Error getting user details: {e}")

    # Replace with your actual starting folder ID

    # Process KIT empty room data

    kit_start_folder_id = get_folder_id_by_path(KIT_EMPTY_ROOM_DATA_PATH)

    # Define the local download directory
    kit_download_directory = r"data/meg-kit"
    os.makedirs(kit_download_directory, exist_ok=True)

    logging.info(f"Downloading empty room files for KIT with limit {KIT_CON_FILE_DOWNLOAD_LIMIT} for .con files")

    download_kit_empty_room_data_from_folder(kit_start_folder_id, kit_download_directory)

    # Process OPM empty room data

    opm_start_folder_id = get_folder_id_by_path(OPM_EMPTY_ROOM_DATA_PATH)
    opm_download_directory = r"data/meg-opm"
    os.makedirs(opm_download_directory, exist_ok=True)

    logging.info(f"Downloading empty room files for OPM with limit {OPM_FIF_FILE_DOWNLOAD_LIMIT} for .fif files")

    download_opm_empty_room_data_from_folder(opm_start_folder_id, opm_download_directory)


except Exception as e:
    logging.error(f"Error during Box authentication setup: {e}")
    logging.info("Skipping Box script and continuing with the Sphinx build.")
    traceback.print_exc()


"""
    # Function to get last modification: files
    try:

        csv_file = "9-dashboard/data/con_files_statistics.csv"

        if os.path.isfile(csv_file):

            df = pd.read_csv(csv_file)
            df["Date"] = pd.to_datetime(df["Date"], format="%d-%m-%y %H:%M:%S")
            df = df.sort_values(by="Date")
            # Get the last modification date
            if not df.empty:
                last_date = df["Date"].iloc[-1].tz_localize(pytz.utc)
            else:
                last_date = None

        else:
            logging.info(f"File {csv_file} does not exist")
            last_date = None
"""
