SUBDIRS=lua-pam

default: all

all clean: $(SUBDIRS)

$(SUBDIRS)::
	$(MAKE) $(MAKEFLAGS) -C $@ $(MAKECMDGOALS)
