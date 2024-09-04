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


def download_con_files_from_folder(folder_id, path, last_date):

    try:
        folder = client.folder(folder_id).get()
        items = folder.get_items(limit=10000, offset=0)

        for item in items:
            try:
                if item.type == "file" and item.name.endswith(".con"):
                    file_id = item.id
                    file = client.file(file_id).get()
                    created_at = datetime.strptime(
                        file.content_created_at, "%Y-%m-%dT%H:%M:%S%z"
                    )
                    if last_date is None or created_at > last_date:
                        created_at = file.content_created_at
                        formatted_date = datetime.strptime(
                            created_at, "%Y-%m-%dT%H:%M:%S%z"
                        ).strftime("%d-%m-%y-%H-%M-%S")
                        filename = f"{formatted_date}_{file.name}"
                        file_path = f"{path}/{filename}"
                        file_path = os.path.join(path, filename)
                        with open(file_path, "wb") as open_file:
                            file.download_to(open_file)
                        print(f"Downloaded {filename} to {file_path}")

                elif item.type == "folder":
                    new_folder_path = os.path.join(path, item.name)
                    os.makedirs(new_folder_path, exist_ok=True)
                    download_con_files_from_folder(item.id, new_folder_path, last_date)
            except Exception as e:
                logging.error(
                    f"Failed to download file or process folder '{item.name}': {str(e)}"
                )
                print(f"Error processing item '{item.name}': {str(e)}")
                traceback.print_exc()

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


def get_file_metadata(file_id):
    box_file = client.file(file_id).get()
    modified_at = box_file.modified_at
    return modified_at


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
        print(f"User ID: {user.id}")
        print(f"User Login: {user.login}")
    except BoxAPIException as e:
        logging.info(f"Error getting user details: {e}")

    # Replace with your actual starting folder ID

    start_folder_id = get_folder_id_by_path(EMPTY_ROOM_DATA_PATH)

    # Define the local download directory
    download_directory = r"data"
    os.makedirs(download_directory, exist_ok=True)

    # Function to get last modification: files
    try:

        csv_file = r"9-dashboard/data/con_files_statistics.csv"

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

        logging.info("Downloading con files")
        # Start the recursive download from the starting folder
        download_con_files_from_folder(start_folder_id, download_directory, last_date)

    except Exception as e:
        logging.error(f"An error occurred in the main script: {str(e)}")
        traceback.print_exc()

except Exception as e:
    logging.error(f"Error during Box authentication setup: {e}")
    logging.info("Skipping Box script and continuing with the Sphinx build.")
    traceback.print_exc()
