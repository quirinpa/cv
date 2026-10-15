#!/bin/sh
# Build embeddable groff fonts from the Inter OpenType family.
#
# gropdf only understands Adobe Type 1 (PFA/PFB), so each OTF is converted
# with fontforge to PFB + AFM, then turned into a groff font-description file
# with afmtodit and registered in the devpdf `download` file.
#
# The result is a self-contained `fonts/devpdf` directory that is passed to
# groff through GROFF_FONT_PATH (see the Makefile).

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
FONTS="$ROOT/fonts"
SRC="$FONTS/src"
DEV="$FONTS/devpdf"

OTF_DIR="${OTF_DIR:-/usr/share/fonts/opentype/inter}"
DEVPDF="${DEVPDF:-/usr/share/groff/1.23.0/font/devpdf}"
ENC="$DEVPDF/enc/text.enc"
MAP="$DEVPDF/map/text.map"

LOG="$SRC/fontbuild.log"
mkdir -p "$SRC" "$DEV"
: >"$LOG"

# groff-name : postscript-name : afmtodit extra flags
#
# Two different names matter:
#   * the *groff* name (first field) is the file name groff/mom look up,
#     built from the family plus a style letter ("Inter" + "R" -> "InterR");
#   * the *PostScript* name (second field) is the font's real name inside the
#     PFB ("Inter-Regular").  gropdf finds the embeddable file by looking up
#     "<foundry> <internalname>" in the download list, so the groff font's
#     `internalname` must be the PostScript name -- hence `afmtodit -f <ps>`.
# -i50 for the italics mirrors how the groff maintainers build their own
# italic fonts (see afmtodit(1)).
STYLES="
InterR:Inter-Regular:
InterB:Inter-Bold:
InterI:Inter-Italic:-i50
InterBI:Inter-BoldItalic:-i50
"

# --- convert + build metrics --------------------------------------------
for entry in $STYLES; do
	name=${entry%%:*}
	rest=${entry#*:}
	ps=${rest%%:*}
	flags=${rest#*:}

	[ -f "$OTF_DIR/$ps.otf" ] || { echo "build-fonts: missing $OTF_DIR/$ps.otf" >&2; exit 1; }

	fontforge -lang=ff -c \
		"Open('$OTF_DIR/$ps.otf'); Generate('$SRC/$ps.pfb'); Generate('$SRC/$ps.afm');" \
		>>"$LOG" 2>&1

	# NOTE: never pipe afmtodit into anything that closes early -- its
	# glyph-mapping warnings cause SIGPIPE and it dies before writing out.
	# shellcheck disable=SC2086
	afmtodit -c -e "$ENC" -f "$ps" $flags \
		"$SRC/$ps.afm" "$MAP" "$DEV/$name" >>"$LOG" 2>&1

	printf 'built %-7s (%-17s) <- %s.otf (%s)\n' "$name" "$ps" "$ps" \
		"$(du -h "$DEV/$name" | cut -f1)"
done

# --- make the device directory self-contained ---------------------------
# Copy DESC, the encodings and the stock download list so groff resolves
# the base-35 fonts too, then append the Inter entries.
cp "$DEVPDF/DESC" "$DEV/DESC"
cp -r "$DEVPDF/enc" "$DEV/enc"
cp "$DEVPDF/download" "$DEV/download"

# ps-font-name is the PostScript name inside the PFB (what fontforge writes);
# the file name column is the absolute path to that PFB.
for entry in $STYLES; do
	name=${entry%%:*}
	rest=${entry#*:}
	ps=${rest%%:*}
	printf '\t%s\t%s\n' "$ps" "$SRC/$ps.pfb" >>"$DEV/download"
done

echo "build-fonts: done -> $DEV"
