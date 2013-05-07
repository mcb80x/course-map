.PHONY: svg dir css swf audio video scripts images

JADE_FILES=${wildcard *.jade}
COFFEE_FILES=${wildcard scripts/*.coffee}
CSS_FILES=${wildcard css/*.css}
SVG_FILES=${wildcard art/*.svg}

all: html js svg css swf audio video scripts images

css: ${CSS_FILES}
	mkdir -p www/css
	cp -r css/* www/css/
	cp -r common/css/* www/css

html: ${JADE_FILES}
	jade --out www/ .

# audio:
# 	mkdir -p www/audio
# 	cp audio/* www/audio/

# images:
# 	mkdir -p www/images
# 	cp images/* www/images/

# video:
# 	mkdir -p www/video
# 	cp video/* www/video/

dir:
	mkdir -p www/js

js: ${COFFEE_FILES} dir
	toaster -d -c

svg:
	mkdir -p www/svg
	cp art/*.* www/svg/

scripts:
	rm -rf www/scripts
	cd www; ln -s ../scripts scripts

swf:
	mkdir -p www/swf
	cp common/third-party/swf/* www/swf/

serve: all
	python server.py