#!/bin/sh
# Extract the CV assets: the nine library logos and the headshot.
#
#   logos  <- ~/site/external/<lib>/assets/logo.png   (alpha flattened to white)
#   photo  <- the 1024x1024 headshot embedded in ~/cv.pdf
#
# Run from anywhere; paths are resolved relative to this script.

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
EXT="${EXT:-$HOME/site/external}"
CV_PDF="${CV_PDF:-$HOME/cv.pdf}"
LOGO_DIR="$ROOT/assets/logos"
PHOTO="$ROOT/assets/photo.png"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$LOGO_DIR"

# --- logos ---------------------------------------------------------------
# <card name>  <source directory under $EXT>
LOGO_MAP='
axil     axil
libxylem libxylem
libbud   libbud
libcorm  libcorm
libhyle  libhyle
libstoma libstoma
libjoint libjoint
libsepal libsepal
libislet libislet
'

echo "$LOGO_MAP" | while read -r name lib; do
	[ -n "$name" ] || continue
	src="$EXT/$lib/assets/logo.png"
	if [ ! -f "$src" ]; then
		echo "extract-assets: missing logo: $src" >&2
		exit 1
	fi
	# gropdf embeds PNGs through ImageMagick; flattening the alpha onto
	# white keeps transparent logos legible on the paper.
	magick "$src" -background white -alpha remove -alpha off \
		"$LOGO_DIR/$name.png"
	printf 'logo  %-9s <- %s (%s)\n' "$name" "$src" \
		"$(magick identify -format '%wx%h' "$LOGO_DIR/$name.png")"
done

# --- photo ---------------------------------------------------------------
if [ ! -f "$CV_PDF" ]; then
	echo "extract-assets: missing source pdf: $CV_PDF" >&2
	exit 1
fi
pdfimages -png "$CV_PDF" "$TMP/img"
# Pick the largest extracted raster; that is the headshot.
big=$(ls -S "$TMP"/img-*.png 2>/dev/null | head -n 1)
if [ -z "$big" ]; then
	echo "extract-assets: no images found in $CV_PDF" >&2
	exit 1
fi
magick "$big" -background white -alpha remove -alpha off "$PHOTO"
printf 'photo            <- %s:%s (%s)\n' "$CV_PDF" "$(basename "$big")" \
	"$(magick identify -format '%wx%h' "$PHOTO")"

echo "extract-assets: done -> $ROOT/assets"
