SUBDIRS=lua-pam

default: all

all clean: $(SUBDIRS)

$(SUBDIRS)::
	$(MAKE) -C $@ $(MAKECMDGOALS)
