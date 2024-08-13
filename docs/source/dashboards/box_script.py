import os
from boxsdk import JWTAuth, Client
from boxsdk.exception import BoxAPIException
from dotenv import load_dotenv
from boxsdk.object.folder import Folder

# load_dotenv(".env")
# Load the configuration from environment variables
client_id = os.getenv("BOX_CLIENT_ID")
client_secret = os.getenv("BOX_CLIENT_SECRET")
enterprise_id = os.getenv("BOX_ENTERPRISE_ID")
public_key_id = os.getenv("BOX_PUBLIC_KEY_ID")

private_key = os.getenv("BOX_PRIVATE_KEY").replace("\\n", "\n").encode()
passphrase = os.getenv("BOX_PASSPHRASE").encode()
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


# Functions to upload and download files...


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
    except FileNotFoundError:
        print(f"File not found: {file_path}")


def get_folder():
    try:
        items = client.folder("0").get_items()
        print("Contents of the root folder:")
        for item in items:
            print(f"Item: {item.name} (ID: {item.id})")
    except BoxAPIException as e:
        print(f"Error fetching folder contents: {e}")


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


# Example: Get the details of the current user
try:
    user = client.user().get()
    print(f"User ID: {user.id}")
    print(f"User Login: {user.login}")
except BoxAPIException as e:
    print(f"Error getting user details: {e}")
# upload_file()


# download_file("Data/empty-room/dataset_description.json", "description.json")


# get_folder()
##################################################################################################

start_folder_id = get_folder_id_by_path("Data/empty-room/sub-emptyroom")

# Define the local download directory
download_directory = "data"
os.makedirs(download_directory, exist_ok=True)


def download_con_files_from_folder(folder_id, path):
    folder = client.folder(folder_id).get()
    items = folder.get_items(limit=100, offset=0)

    for item in items:
        if item.type == "file" and item.name.endswith(".con"):
            file_id = item.id
            file = client.file(file_id).get()
            file_path = os.path.join(path, file.name)
            with open(file_path, "wb") as open_file:
                file.download_to(open_file)
            print(f"Downloaded {file.name} to {file_path}")

        elif item.type == "folder":
            new_folder_path = os.path.join(path, item.name)
            os.makedirs(new_folder_path, exist_ok=True)
            download_con_files_from_folder(item.id, new_folder_path)


# Start the recursive download from the starting folder
download_con_files_from_folder(start_folder_id, download_directory)
