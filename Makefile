default:
	@echo "TARGETS: all | fonts | images | pdf | clean | view"
all: fonts images pdf

fonts:
	@scripts/build-fonts.sh
images:
	@scripts/build-images.sh
pdf:
	@if [ ! -f fonts/devpdf/InterR ]; then scripts/build-fonts.sh; fi
	@if [ ! -f assets/pdf/axil.pdf ]; then scripts/build-images.sh; fi
	GROFF_FONT_PATH=$(CURDIR)/fonts pdfmom -t -k cv.mom > cv.pdf 2>build.log
	@cat build.log
	@echo "---- build pdfinfo ----"
	@pdfinfo cv.pdf | grep -E 'Pages|Page size'

clean:
	rm -rf fonts/src/*.afm fonts/src/*.pfb fonts/src/fontbuild.log fonts/devpdf/* assets/pdf/*.pdf cv.pdf build.log

view:
	xdg-open cv.pdf 2>/dev/null &

.PHONY: all default fonts images pdf clean view
