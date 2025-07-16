#!/usr/bin/env python3

from PIL import Image
import sys
import os

# === Configuration ===
DPI = 300
CM_TO_INCH = 2.54

# Photo size and spacing
PHOTO_WIDTH_CM, PHOTO_HEIGHT_CM = 3.5, 4.5
PHOTO_WIDTH_PX = int(PHOTO_WIDTH_CM / CM_TO_INCH * DPI)    # ~413 px
PHOTO_HEIGHT_PX = int(PHOTO_HEIGHT_CM / CM_TO_INCH * DPI)  # ~531 px
SPACING_MM = 3
SPACING_PX = int((SPACING_MM / 10) * DPI / CM_TO_INCH)     # ~35 px

# A4 size and margins
A4_WIDTH_PX = int(8.27 * DPI)   # 2480 px
A4_HEIGHT_PX = int(11.69 * DPI) # 3508 px
MARGIN_MM = 6
MARGIN_PX = int((MARGIN_MM / 10) * DPI / CM_TO_INCH)       # ~118 px

def resize_to_fill_and_crop(image):
    """Resize the image to fill 3.5x4.5cm at 300 DPI and crop to exact size."""
    original_width, original_height = image.size

    if original_width < 50 or original_height < 50:
        raise ValueError("Image too small to resize to 3.5x4.5cm at 300 DPI.")

    scale = max(PHOTO_WIDTH_PX / original_width, PHOTO_HEIGHT_PX / original_height)
    new_width = int(original_width * scale)
    new_height = int(original_height * scale)

    image = image.resize((new_width, new_height), Image.LANCZOS)

    # Crop to center
    left = (new_width - PHOTO_WIDTH_PX) // 2
    top = (new_height - PHOTO_HEIGHT_PX) // 2
    right = left + PHOTO_WIDTH_PX
    bottom = top + PHOTO_HEIGHT_PX

    return image.crop((left, top, right, bottom))

def create_photo_grid(image_path):
    img = Image.open(image_path)

    try:
        processed = resize_to_fill_and_crop(img)
    except ValueError as e:
        print(f"❌ {e}")
        return

    canvas = Image.new("RGB", (A4_WIDTH_PX, A4_HEIGHT_PX), "white")

    # Usable space after margins
    usable_width = A4_WIDTH_PX - 2 * MARGIN_PX
    usable_height = A4_HEIGHT_PX - 2 * MARGIN_PX

    block_width = PHOTO_WIDTH_PX + SPACING_PX
    block_height = PHOTO_HEIGHT_PX + SPACING_PX

    cols = (usable_width + SPACING_PX) // block_width
    rows = (usable_height + SPACING_PX) // block_height

    print(f"📸 Placing {cols} x {rows} photos with 3mm spacing and 10mm margins")

    for row in range(rows):
        for col in range(cols):
            x = MARGIN_PX + col * block_width
            y = MARGIN_PX + row * block_height
            canvas.paste(processed, (x, y))

    # Save output in same folder
    base_dir = os.path.dirname(image_path)
    base_name = os.path.splitext(os.path.basename(image_path))[0]
    output_path = os.path.join(base_dir, f"{base_name}_photo_grid.jpg")

    canvas.save(output_path, dpi=(DPI, DPI), quality=95)
    print(f"✅ Saved photo grid to: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ./create_photo_grid.py path_to_photo.jpg")
        sys.exit(1)

    input_path = sys.argv[1]
    if not os.path.exists(input_path):
        print("❌ File does not exist.")
        sys.exit(1)

    create_photo_grid(input_path)

