import os
import requests
from tqdm import tqdm

# Constants
BASE_URL = "https://cloud-images.ubuntu.com/noble/current/"
IMAGE_NAME = "noble-server-cloudimg-amd64.img"
DOWNLOAD_DIR = "images"
IMAGE_PATH = os.path.join(DOWNLOAD_DIR, IMAGE_NAME)


def download_image():
    os.makedirs(DOWNLOAD_DIR, exist_ok=True)

    if os.path.exists(IMAGE_PATH):
        print(f"[INFO] Image already exists: {IMAGE_PATH}")
        return

    url = BASE_URL + IMAGE_NAME
    print(f"[INFO] Downloading: {url}")

    response = requests.get(url, stream=True)
    response.raise_for_status()

    total_size = int(response.headers.get('content-length', 0))

    with open(IMAGE_PATH, "wb") as file, tqdm(
        desc=IMAGE_NAME,
        total=total_size,
        unit='iB',
        unit_scale=True,
        unit_divisor=1024,
    ) as bar:
        for chunk in response.iter_content(chunk_size=1024):
            size = file.write(chunk)
            bar.update(size)

    print(f"[SUCCESS] Downloaded to: {IMAGE_PATH}")


if __name__ == "__main__":
    download_image()