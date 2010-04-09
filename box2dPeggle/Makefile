
HAXE    = haxe
SWFMILL = swfmill
PROJECT = Puggle

SOURCES = $(wildcard src/*.hx src/**/*.hx)
ASSETS  = $(wildcard res/img/* res/snd/*)

all:	$(PROJECT).swf

$(PROJECT).swf:	$(SOURCES) haxe.hxml res/library.swf gen/AssetClasses.hx
	$(HAXE) haxe.hxml -main $(PROJECT) -swf9 $(PROJECT).swf

res/library.swf:	res/library.xml $(ASSETS)

clean:
	rm -f *.swf
	rm -f dist/*
	rm -f res/*.swf
	rm -rf gen

%.swf:	%.xml
	@cd $(dir $<); \
	$(SWFMILL) -v simple $(notdir $<) $(notdir $@)

gen/AssetClasses.hx: res/library.xml library.xslt
	xsltproc -o $@ library.xslt $<
	

