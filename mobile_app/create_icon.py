#!/usr/bin/env python3
"""
Generate custom E-Receipt app icons
Creates a receipt-themed icon with orange color scheme
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_receipt_icon(size, output_path, is_adaptive=False):
    """Create a receipt-themed icon"""
    # Create image with transparent background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Colors
    orange = (255, 107, 53, 255)  # #FF6B35
    white = (255, 255, 255, 255)
    dark_orange = (230, 90, 40, 255)
    light_orange = (255, 150, 100, 255)

    # Calculate padding
    padding = size * 0.15 if not is_adaptive else size * 0.25

    # Receipt paper dimensions
    receipt_width = size - (padding * 2)
    receipt_height = size - (padding * 2)
    receipt_x = padding
    receipt_y = padding

    # Draw receipt paper with shadow
    shadow_offset = size * 0.02
    draw.rounded_rectangle(
        [receipt_x + shadow_offset, receipt_y + shadow_offset,
         receipt_x + receipt_width + shadow_offset, receipt_y + receipt_height + shadow_offset],
        radius=size * 0.08,
        fill=(0, 0, 0, 80)
    )

    # Draw receipt paper
    draw.rounded_rectangle(
        [receipt_x, receipt_y, receipt_x + receipt_width, receipt_y + receipt_height],
        radius=size * 0.08,
        fill=white
    )

    # Draw receipt top tear edge (zigzag pattern)
    tear_height = size * 0.08
    tear_points = []
    num_teeth = 8
    tooth_width = receipt_width / num_teeth

    for i in range(num_teeth + 1):
        x = receipt_x + (i * tooth_width)
        y = receipt_y if i % 2 == 0 else receipt_y + tear_height
        tear_points.append((x, y))

    # Add bottom points to close the shape
    tear_points.append((receipt_x + receipt_width, receipt_y + tear_height))
    tear_points.append((receipt_x, receipt_y + tear_height))

    draw.polygon(tear_points, fill=orange)

    # Draw receipt lines (items)
    line_start_y = receipt_y + tear_height + (size * 0.12)
    line_spacing = size * 0.08
    line_margin = size * 0.12

    # Draw 4 receipt item lines
    for i in range(4):
        y = line_start_y + (i * line_spacing)
        # Item name line (left)
        draw.rounded_rectangle(
            [receipt_x + line_margin, y,
             receipt_x + receipt_width * 0.6, y + size * 0.025],
            radius=size * 0.01,
            fill=light_orange if i % 2 == 0 else orange
        )
        # Price line (right)
        draw.rounded_rectangle(
            [receipt_x + receipt_width * 0.7, y,
             receipt_x + receipt_width - line_margin, y + size * 0.025],
            radius=size * 0.01,
            fill=dark_orange if i % 2 == 0 else orange
        )

    # Draw total line (thicker, at bottom)
    total_y = receipt_y + receipt_height - (size * 0.15)
    draw.rounded_rectangle(
        [receipt_x + line_margin, total_y,
         receipt_x + receipt_width - line_margin, total_y + size * 0.04],
        radius=size * 0.015,
        fill=orange
    )

    # Draw checkmark or PDF symbol in corner
    icon_size = size * 0.18
    icon_x = receipt_x + receipt_width - icon_size - (size * 0.08)
    icon_y = receipt_y + receipt_height - icon_size - (size * 0.08)

    # Draw circular background
    draw.ellipse(
        [icon_x, icon_y, icon_x + icon_size, icon_y + icon_size],
        fill=orange
    )

    # Draw checkmark
    check_width = size * 0.025
    check_points = [
        (icon_x + icon_size * 0.3, icon_y + icon_size * 0.5),
        (icon_x + icon_size * 0.45, icon_y + icon_size * 0.7),
        (icon_x + icon_size * 0.75, icon_y + icon_size * 0.35),
    ]

    for i in range(len(check_points) - 1):
        draw.line(
            [check_points[i], check_points[i + 1]],
            fill=white,
            width=int(check_width * 1.5)
        )

    # Save the image
    img.save(output_path, 'PNG')
    print(f"Created icon: {output_path} ({size}x{size})")

def main():
    # Get the directory where this script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    assets_dir = os.path.join(script_dir, 'assets', 'images')

    # Create assets directory if it doesn't exist
    os.makedirs(assets_dir, exist_ok=True)

    # Create main app icon (1024x1024)
    print("Creating app icons...")
    create_receipt_icon(1024, os.path.join(assets_dir, 'app_icon.png'), is_adaptive=False)

    # Create adaptive icon foreground (1024x1024 with more padding)
    create_receipt_icon(1024, os.path.join(assets_dir, 'app_icon_foreground.png'), is_adaptive=True)

    print("\nIcons created successfully!")
    print(f"Location: {assets_dir}")
    print("\nNext steps:")
    print("1. Run: flutter pub run flutter_launcher_icons")
    print("2. Run: flutter clean && flutter run")

if __name__ == '__main__':
    main()
