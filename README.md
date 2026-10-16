# Paulo Quirino — Curriculum Vitae

A high-performance, reproducible technical CV typeset in pure GNU Troff (`pdfmom`) using the **Inter** OpenType font family.

- **Page 1**: Commercial engineering leadership, production impact, and a categorized skills matrix (Systems & C, Full-Stack & Databases, AI & DevOps, Leisure).
- **Page 2**: Comprehensive architectural showcase of **The Pure-C Application Engine Stack** (`axil`, `libbud`, `libsepal`, `libstoma`, etc.) and core systems invariants.

---

## 1. Prerequisites & Installation

Building requires `groff` (1.23+ with `pdfmom` and `gropdf`), `fontforge` (to convert OTF fonts to Type 1 PFB/AFM for groff), ImageMagick (to preprocess embedded images), `poppler-utils` (to verify page metrics), and the **Inter** font family.

### Debian / Ubuntu

```bash
sudo apt update && sudo apt install -y \
  groff \
  fontforge \
  imagemagick \
  poppler-utils \
  fonts-inter
```

> **Note**: Verify that Inter is present at `/usr/share/fonts/opentype/inter/Inter-Regular.otf`. If installed to a different location, override `OTF_DIR` when building fonts:
> ```bash
> OTF_DIR=/path/to/inter make fonts
> ```

---

## 2. Project & Asset Staging

```
.
├── Makefile                # Build automation
├── README.md               # Documentation
├── .gitignore              # Ignores build artifacts (fonts/devpdf, assets/pdf, cv.pdf)
├── cv.mom                  # Primary CV content in GNU Troff / mom
├── style.mom               # Styling engine: geometry, typography, palette, and macros
├── assets/
│   ├── portrait.png        # Primary illustrated portrait asset (with native light background)
│   ├── photo.png           # (Alternative) Portrait photograph
│   └── logos/              # (Optional) Library PNG logos
└── scripts/
    ├── build-fonts.sh      # Compiles OTF Inter fonts into groff Type 1 devpdf metrics
    ├── build-images.sh     # Scales and converts PNG assets into assets/pdf/*.pdf
    └── extract-assets.sh   # Extracts submodule logos from ~/site/external if needed
```

### Staging Needed Files

1. **Portrait Image (`assets/portrait.png`)**:
   Ensure `assets/portrait.png` exists in `assets/`. `scripts/build-images.sh` will scale and density-correct it into `assets/pdf/portrait.pdf` for embedding in the header. (Falls back to `assets/photo.png` if `portrait.png` is absent).
2. **Font Generation**:
   Fonts are generated dynamically from system OTF files and stored under `fonts/devpdf/` and `fonts/src/` (ignored by Git).
3. **Logos (`assets/logos/`)**:
   If using visual logo embeds, place PNGs in `assets/logos/` (or run `scripts/extract-assets.sh` if building alongside `site/external`).

### Visual Design System

- **Retro-Technical Aesthetic**: Inspired by 1980s engineering drafting and technical typography.
- **Rhythmic Background Pattern**: Native groff vector vertical drafting rules (`.BG_PATTERN`) providing subtle margin guides, column boundaries in faint teal (`#EBF4F3`), and a sleek teal corner triangle in the top right.
- **Homogeneous Skill & Category Tags**: Bracketed retro-terminal pills (`.PILL`, `[tag]`) with subtle background highlight (`#EBF4F3`), atomic line-fit bounds, slate borders, and teal text.
- **Pure-C Architecture Showcase**: Two-column layout detailing the C stack on Page 2, concluding with a symmetrical two-column grid of 4 Core Architectural Invariants (*Zero Dependencies*, *Deterministic Latency*, *Unified Isomorphism*, and *Strict ABI Isolation*).

---

## 3. Build Instructions

### Build Targets

```bash
make all      # Builds fonts, pre-processes images, and compiles cv.pdf
make pdf      # Compiles cv.mom to cv.pdf (auto-builds fonts/images if absent)
make fonts    # Generates fonts/devpdf from system Inter OTF files
make images   # Generates assets/pdf/*.pdf from assets/photo.png
make clean    # Deletes all generated artifacts (PDF, devpdf fonts, image PDFs)
make view     # Opens cv.pdf in default PDF viewer
```

### Manual Compilation

To invoke `pdfmom` directly with local font paths:

```bash
GROFF_FONT_PATH=$(pwd)/fonts pdfmom -t -k cv.mom > cv.pdf
```

- `-t`: Enables the `tbl(1)` preprocessor for two-column grids.
- `-k`: Enables the `preconv(1)` preprocessor for UTF-8 character conversion.

---

## 4. Git Staging & Publishing

To push this repository to GitHub:

```bash
git add Makefile README.md .gitignore cv.mom scripts/ assets/photo.png
git commit -m "feat: typeset CV in GNU Troff with Pure-C stack showcase"

# Link to GitHub
git remote add origin git@github.com:quirinpa/cv.git
git branch -M main
git push -u origin main
```
