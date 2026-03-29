from PIL import Image, ImageDraw
import os
import math

SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Rounded rectangle gradient background
for y in range(SIZE):
    t = y / SIZE
    r = int(61 + t * 20)   # 61 → 81
    g = int(59 + t * 10)   # 59 → 69
    b = int(243 - t * 30)  # 243 → 213
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

mask = Image.new('L', (SIZE, SIZE), 0)
mask_draw = ImageDraw.Draw(mask)
radius = 200
mask_draw.rounded_rectangle([0, 0, SIZE, SIZE], radius=radius, fill=255)
img.putalpha(mask)

# Draw stylized spark/star shape in white
cx, cy = SIZE // 2, SIZE // 2
points = []
spikes = 4
outer = 280
inner = 120
for i in range(spikes * 2):
    angle = math.pi / spikes * i - math.pi / 4
    r = outer if i % 2 == 0 else inner
    points.append((cx + math.cos(angle) * r, cy + math.sin(angle) * r))

draw.polygon(points, fill=(255, 255, 255, 255))

# Small center circle
dot = 60
draw.ellipse([cx-dot, cy-dot, cx+dot, cy+dot], fill=(61, 59, 243, 255))

# Save background icon
os.makedirs('assets/icon', exist_ok=True)
img.save('assets/icon/icon.png')

# Save foreground icon for adaptive icon
fg = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
fg_draw = ImageDraw.Draw(fg)
fg_draw.polygon(points, fill=(255, 255, 255, 255))
fg_draw.ellipse([cx-dot, cy-dot, cx+dot, cy+dot], fill=(61, 59, 243, 255))
fg.save('assets/icon/icon_foreground.png')

print('Icon generated successfully')