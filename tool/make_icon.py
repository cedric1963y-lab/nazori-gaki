"""App icon for なぞり書き: a cream 祝儀袋 on vermillion washi, a brush-script 寿
whose upper half is inked in sumi and lower half still a grey guide (tracing),
and a red-gold 水引 with an awaji knot."""
import math, random
from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageChops

S = 4096
k = S / 1024
def r(v): return int(round(v * k))

img = Image.new("RGB", (S, S))
d = ImageDraw.Draw(img)
top, bot = (196, 70, 48), (146, 40, 30)
for y in range(S):
    t = y / (S - 1)
    d.line([(0, y), (S, y)], fill=tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3)))

# washi fibers on the background
rnd = random.Random(5)
fib = Image.new("L", (S, S), 0)
fd = ImageDraw.Draw(fib)
for _ in range(2600):
    x, y = rnd.uniform(0, S), rnd.uniform(0, S)
    a = rnd.uniform(0, math.pi); L = rnd.uniform(r(8), r(34))
    fd.line([(x, y), (x + math.cos(a) * L, y + math.sin(a) * L)], fill=rnd.randint(25, 60), width=rnd.randint(2, 5))
img = Image.composite(Image.new("RGB", (S, S), (236, 150, 120)), img, fib)

# envelope shadow + body
ex0, ey0, ex1, ey1 = r(272), r(96), r(752), r(944)
sh = Image.new("L", (S, S), 0)
ImageDraw.Draw(sh).rectangle([ex0 + r(10), ey0 + r(22), ex1 + r(10), ey1 + r(22)], fill=150)
sh = sh.filter(ImageFilter.GaussianBlur(r(24)))
img = Image.composite(Image.new("RGB", (S, S), (90, 20, 14)), img, sh)
d = ImageDraw.Draw(img)
d.rectangle([ex0, ey0, ex1, ey1], fill=(251, 247, 238))
# wrapping fold: a slightly darker panel on the left edge
d.polygon([(ex0, ey0), (ex0 + r(54), ey0), (ex0 + r(54), ey1), (ex0, ey1)], fill=(240, 233, 220))
d.line([(ex0 + r(54), ey0), (ex0 + r(54), ey1)], fill=(226, 216, 199), width=r(3))

# 寿 : grey guide, with the upper part inked
font = ImageFont.truetype("assets/fonts/YujiSyuku-Regular.ttf", r(372))
glyph = Image.new("L", (S, S), 0)
gd = ImageDraw.Draw(glyph)
cx, cy = r(540), r(370)
gd.text((cx, cy), "寿", font=font, fill=255, anchor="mm")
cut = r(348)
upper = Image.new("L", (S, S), 0)
ImageDraw.Draw(upper).polygon([(0, 0), (S, 0), (S, cut - r(26)), (0, cut + r(26))], fill=255)
inked = ImageChops.multiply(glyph, upper)
guide = ImageChops.subtract(glyph, inked)
img = Image.composite(Image.new("RGB", (S, S), (196, 188, 176)), img, guide)
# dotted outline feel for the guide: soften slightly
img = Image.composite(Image.new("RGB", (S, S), (28, 24, 21)), img, inked)
d = ImageDraw.Draw(img)

# 水引 cords across the envelope
band_y = r(712)
cords = [(214, 170, 76), (214, 170, 76), (200, 52, 42), (200, 52, 42), (200, 52, 42)]
cw = r(13)
for i, c in enumerate(cords):
    y = band_y + (i - 2) * int(cw * 1.25)
    d.line([(ex0, y), (ex1, y)], fill=c, width=cw)

# awaji knot: three interlocked loops drawn as thick arcs
def loop(box, start, end, color, w):
    d.arc(box, start, end, fill=color, width=w)

kx, ky = r(526), band_y
# knock out the cords inside the loops so the knot reads as loops on top
paper = (251, 247, 238)
d.ellipse([kx - r(176), ky - r(76), kx - r(4), ky + r(76)], fill=paper)
d.ellipse([kx + r(4), ky - r(76), kx + r(176), ky + r(76)], fill=paper)
d.ellipse([kx - r(76), ky - r(156), kx + r(76), ky + r(16)], fill=paper)
for i, c in enumerate([(200, 52, 42), (214, 170, 76)]):
    off = i * r(15)
    w = r(16)
    # left and right loops
    loop([kx - r(170) + off, ky - r(70) + off, kx - r(10) - off, ky + r(70) - off], 0, 360, c, w)
    loop([kx + r(10) + off, ky - r(70) + off, kx + r(170) - off, ky + r(70) - off], 0, 360, c, w)
    # upper loop
    loop([kx - r(70) + off, ky - r(150) + off, kx + r(70) - off, ky + r(10) - off], 150, 390, c, w)
# center tie
d.rounded_rectangle([kx - r(26), ky - r(36), kx + r(26), ky + r(36)], radius=r(10), fill=(200, 52, 42))
d.rounded_rectangle([kx - r(10), ky - r(36), kx + r(10), ky + r(36)], radius=r(6), fill=(214, 170, 76))

# dotted guide for the name below the knot
for i in range(4):
    y = band_y + r(118) + i * r(30)
    d.rounded_rectangle([kx - r(7), y, kx + r(7), y + r(16)], radius=r(7), fill=(204, 196, 184))

# small noshi at upper right
nx, ny, ns = r(690), r(150), r(34)
pts = [(nx, ny - ns * 1.3), (nx + ns * 0.75, ny - ns * 0.25), (nx + ns * 0.4, ny + ns * 1.4), (nx - ns * 0.4, ny + ns * 1.4), (nx - ns * 0.75, ny - ns * 0.25)]
d.polygon(pts, fill=(255, 255, 255), outline=(200, 52, 42))
d.line(pts + [pts[0]], fill=(200, 52, 42), width=r(4))
d.line([(nx, ny - ns * 0.3), (nx, ny + ns * 1.1)], fill=(226, 179, 60), width=r(10))

img = img.resize((1024, 1024), Image.LANCZOS)
img.save("assets/icon/app_icon.png", optimize=True)
print("ok")
