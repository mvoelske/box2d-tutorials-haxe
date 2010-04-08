
HAXE    = haxe
SWFMILL = swfmill
PROJECT = HelloBoxWorld

SOURCES = $(wildcard *.hx)
#ASSETS  = $(wildcard resource/img/* resource/snd/*)

all:	$(PROJECT).swf

$(PROJECT).swf:	$(SOURCES) haxe.hxml
	$(HAXE) haxe.hxml -main $(PROJECT) -swf9 $(PROJECT).swf

#resource/library.swf:	resource/library.xml $(ASSETS)

clean:
	rm -f *.swf
	rm -f dist/*
	rm -f resource/*.swf

%.swf:	%.xml
	@cd $(dir $<); \
	$(SWFMILL) -v simple $(notdir $<) $(notdir $@)

