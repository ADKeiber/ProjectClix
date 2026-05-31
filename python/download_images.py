
import json
import os
import requests
from urllib.parse import urlparse

JSON_FILE = "units.json"
OUTPUT_DIR = "images"

# =========================================================
# IMAGE FIELD MAP
# =========================================================
#
# FIGURE
# ti = tokenImage
#
# TERRAIN
# iu = imageURL
#
# TERRAIN_MARKER
# iu = imageURL
#
# EQUIPMENT
# i = image
#
# BYSTANDER
# iu = imageURL
#
# SPECIAL_OBJECT
# iu = imageURL
#
# ONE_SHOT
# au = artURL
#
# MAP
# (currently no image)
#
# =========================================================

IMAGE_FIELDS = {
    "FIGURE": "ti",
    "": "ti",
    "TERRAIN": "iu",
    "TERRAIN_MARKER": "iu",
    "EQUIPMENT": "i",
    "BYSTANDER": "iu",
    "SPECIAL_OBJECT": "iu",
    "ONE_SHOT": "au",
}


# =========================================================
# HELPERS
# =========================================================

def get_extension(url):

    path = urlparse(url).path

    _, ext = os.path.splitext(path)

    if ext:
        return ext

    return ".png"


# =========================================================
# LOAD JSON
# =========================================================

with open(JSON_FILE, "r", encoding="utf-8") as f:
    data = json.load(f)


# =========================================================
# CREATE OUTPUT DIR
# =========================================================

os.makedirs(OUTPUT_DIR, exist_ok=True)


# =========================================================
# DOWNLOAD IMAGES
# =========================================================

success = 0
failed = 0
skipped = 0

for unit_id, unit_data in data.items():

    # older figure entries may not have a tp field
    # default them to FIGURE
    unit_type = unit_data.get("tp", "FIGURE")

    if unit_type not in IMAGE_FIELDS:

        skipped += 1

        print(f"SKIP [{unit_id}] Unknown type: {unit_type}")

        continue

    image_field = IMAGE_FIELDS[unit_type]

    image_url = unit_data.get(image_field)

    if not image_url:

        skipped += 1

        print(f"SKIP [{unit_id}] Missing image URL")

        continue

    try:

        ext = get_extension(image_url)

        output_path = os.path.join(
            OUTPUT_DIR,
            f"{unit_id}{ext}"
        )

        # skip if already downloaded
        if os.path.exists(output_path):

            skipped += 1

            print(f"EXISTS [{unit_id}]")

            continue

        response = requests.get(
            image_url,
            timeout=20
        )

        response.raise_for_status()

        with open(output_path, "wb") as img_file:
            img_file.write(response.content)

        success += 1

        print(f"DOWNLOADED [{unit_id}]")

    except Exception as e:

        failed += 1

        print(f"FAILED [{unit_id}] {e}")


# =========================================================
# SUMMARY
# =========================================================

print()
print("============================")
print(f"Downloaded: {success}")
print(f"Skipped:    {skipped}")
print(f"Failed:     {failed}")
print("============================")