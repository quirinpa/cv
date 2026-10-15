#!/bin/sh
# Turn the PNG assets into the PDF images that mom's PDF_IMAGE expects.
#
# Every logo is trimmed to its artwork, scaled to ONE common height and laid
# flush into the top-left of an IDENTICAL canvas.  That gives the roster a
# single left edge (every logo starts at the same x), a single optical size
# (every logo is the same height, whatever its aspect ratio) and a single
# baseline, so nothing can drift out of line from logo to logo.
#
# Canvas: 52 x 34 pt, rasterised at 4x (288 dpi) so the embed stays crisp.
# Keep CANVAS_* here in step with the dimensions passed to PDF_IMAGE in cv.mom.

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
LOGO_DIR="$ROOT/assets/logos"
PDF_DIR="$ROOT/assets/pdf"

CANVAS_W=208	# px == 52 pt at 288 dpi
CANVAS_H=136	# px == 34 pt at 288 dpi
DPI=288

mkdir -p "$PDF_DIR"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

for f in "$LOGO_DIR"/*.png; do
	[ -e "$f" ] || continue
	name=$(basename "$f" .png)
	# Two passes: IM's PDF writer keeps the pre-trim resolution when the
	# canvas is built and encoded in one go, and the page comes out the wrong
	# size; a PNG round-trip resets it.
	magick "$f" -fuzz 2% -trim +repage \
		-resize "x$CANVAS_H" \
		-background white -gravity northwest -extent "${CANVAS_W}x${CANVAS_H}" \
		"$TMP/$name.png"
	magick "$TMP/$name.png" -units PixelsPerInch -density "$DPI" \
		"$PDF_DIR/$name.pdf"
	printf 'image %-9s -> %s (%s)\n' "$name" \
		"$(basename "$PDF_DIR/$name.pdf")" \
		"$(pdfinfo "$PDF_DIR/$name.pdf" | sed -n 's/^Page size: *//p')"
done

if [ -f "$ROOT/assets/portrait.png" ]; then
	magick "$ROOT/assets/portrait.png" -resize 300x300 -units PixelsPerInch -density 72 \
		"$PDF_DIR/portrait.pdf"
	printf 'image %-9s -> portrait.pdf (%s)\n' portrait \
		"$(pdfinfo "$PDF_DIR/portrait.pdf" | sed -n 's/^Page size: *//p')"
fi

if [ -f "$ROOT/assets/photo.png" ]; then
	magick "$ROOT/assets/photo.png" -resize 300x300 -units PixelsPerInch -density 72 \
		"$PDF_DIR/photo.pdf"
	printf 'image %-9s -> photo.pdf (%s)\n' photo \
		"$(pdfinfo "$PDF_DIR/photo.pdf" | sed -n 's/^Page size: *//p')"
fi

echo "build-images: done -> $PDF_DIR"
