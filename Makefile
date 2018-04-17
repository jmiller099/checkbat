# Dependency generation lifted from:
# http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
# With some modifications to the include pattern
# furthermore modifications to the depend flags
#
# Usage:
#
# make                      - This will make a debug variant
# make launch               - This will make a debug variant then run it
# make all                  - This will make debug then release
# make OUTDIR=rel release   - This will make release build
# make clean                - This will clean debug and release
# make niceclean            - This will keep binaries and clean intermediates
#
# The following are useful during development and debugging
# Generally found in dbg/inter directory when completed
# make srcfile.o            - This will compile a src to obj (dbg)
# make srcfile.pre          - This will preprocess a src to pre (dbg)
# make srcfile.s            - This will compile a src to assembly (dbg)
# make inspector            - This will make the three above and one below
# Following may not be working right now
# make srcfile.dp           - This will make a src into an intermixed dump (dbg)


TARGET	=	checkbat
EXETYPE	=	out

OBJFILES	=	$(INTERDIR)/$(TARGET).o \

PREFILES	=	$(OBJFILES:.o=.pre)
SFILES		=	$(OBJFILES:.o=.s)
DPFILES		=	$(OBJFILES:.o=.dp)

LIBS		=	

CC		=	gcc
LD		=	gcc
DUMPTOOL	=	objdump

OUTDIR		=
INTERDIR	=
DEPDIR		=

RDIR		= 	rel
DDIR		=	dbg

INC		=	

#  Default targets are debug, so max info can be had
#  For release target: invoke make release
#  To alter the compile flags, check the release: target
CFLAGS		= -g -DDEBUG
CPPFLAGS	= -g -DDEBUG

LDFLAGS		=
OUTDIR		= $(DDIR)
INTERDIR	= $(OUTDIR)/inter
DEPDIR		= $(INTERDIR)/.d
#DEPFLAGS	= -MT $@ -MMD -MP -MF $(DEPDIR)/$*.Td
DEPFLAGS	= -MMD -MP -MF $(DEPDIR)/$*.Td

# Default is debug build
default: $(INTERDIR) $(DEPDIR) $(OUTDIR)/$(TARGET)

# Make debug and release build
all: $(INTERDIR) $(DEPDIR) $(OUTDIR)/$(TARGET)
	make OUTDIR=rel release

# Generates a lot of binary analysis files
inspector: $(INTERDIR) $(DEPDIR) $(PREFILES) $(SFILES) $(DPFILES) $(INTERDIR)/$(TARGET).$(EXETYPE) $(INTERDIR)/$(TARGET).dump $(OUTDIR)/$(TARGET)

# The release build
release:	CFLAGS		= -O3
release:	CPPFLAGS	= -O3
release:	LDFLAGS		=
release:	OUTDIR		= $(RDIR)
release:	INTERDIR	= $(RDIR)/inter
release:	$(INTERDIR) $(DEPDIR) $(OUTDIR)/$(TARGET)


.c$.o:
	$(CC) -c $(CFLAGS) -o $@ $< 

.cpp.o:
	$(CC) -c $(CPPFLAGS) -o $@ $< 

# Rules for the object files
$(INTERDIR)/%.o: %.c $(DEPDIR)/%.d
	$(CC) $(DEPFLAGS) -c $(CFLAGS) -o $@ $< 
	mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d && touch $@

# Shortcut to do make file.o instead of full path
# Won't be friendly on larger projects with many directories
%.o: %.c $(INTERDIR)
	$(CC) -c $(CFLAGS) -o $(INTERDIR)/$@ $< 

$(INTERDIR)/%.o: %.cpp
	$(CC) -c $(CPPFLAGS) -o $@ $< 

%.o: %.cpp $(INTERDIR)
	$(CC) -c $(CPPFLAGS) -o $(INTERDIR)/$@ $< 

$(INTERDIR)/%.s: %.c
	$(CC) $(CFLAGS) -S $< -o $@

%.s: %.c $(INTERDIR)
	$(CC) $(CFLAGS) -S $< -o $(INTERDIR)/$@

$(INTERDIR)/%.pre: %.c
	$(CC) $(CFLAGS) -E $< > $@

%.pre: %.c $(INTERDIR)
	$(CC) $(CFLAGS) -E $< > $(INTERDIR)/$@

$(INTERDIR)/%.dp: %.c
	$(CC) $(CFLAGS) -S -dp $< -o $@

%.dp: %.c $(INTERDIR)
	$(CC) $(CFLAGS) -S -dp $< -o $(INTERDIR)/$@

$(INTERDIR)/%.dump: $(INTERDIR)/$(TARGET).$(EXETYPE)
	$(DUMPTOOL) -x -s $< > $@

%.dump: $(INTERDIR)/$(TARGET).$(EXETYPE)
	$(DUMPTOOL) -x -s $< > $(INTERDIR)/$@

$(DEPDIR)/%.d: ;

.PRECIOUS:	$(DEPDIR)/%.d

#$(TARGET):	$(TARGET).$(EXETYPE) 
#$(TARGET):	$(OUTDIR) $(INTERDIR) $(INTERDIR)/$(TARGET).$(EXETYPE) 
#$(OUTDIR)/$(TARGET):	$(INTERDIR)/$(TARGET).$(EXETYPE) $(OUTDIR) $(INTERDIR)
$(OUTDIR)/$(TARGET):	$(INTERDIR)/$(TARGET).$(EXETYPE) 
	@echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	@echo Fixing permissions
	@echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	cp $< $@
	ldid -S $@
	@echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	@echo Completed build
	@echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

$(OUTDIR):
	$(shell mkdir -p $(OUTDIR) >/dev/null)
	@echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	@echo Compiling source files
	@echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-

$(INTERDIR):	$(OUTDIR)
	$(shell mkdir -p $(INTERDIR) >/dev/null)

$(DEPDIR):	$(INTERDIR)
	$(shell mkdir -p $(DEPDIR) >/dev/null)

$(INTERDIR)/$(TARGET).$(EXETYPE) :	$(OBJFILES)
	@echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	@echo Linking executable
	@echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	$(LD) -o $@ $(LDFLAGS) \
	$(OBJFILES) $(LIBS) 

# Clean everything that make generates
clean:
	if [ -d "$(RDIR)" ]; then rm -r $(RDIR); fi
	if [ -d "$(DDIR)" ]; then rm -r $(DDIR); fi

# Keep the binaries
niceclean:
	if [ -d "$(RDIR)/inter" ]; then rm -r $(RDIR)/inter; fi
	if [ -d "$(DDIR)/inter" ]; then rm -r $(DDIR)/inter; fi

#include $(patsubst %.o,%.d,$(subst $(INTERDIR),$(DEPDIR),$(OBJFILES)))
#include $(wildcard $(patsubst %,$(DEPDIR)/%.d,$(basename $(OBJFILES))))
#include $(patsubst %, $(DEPDIR)/%.d, $(basename $(OBJFILES)))
include $(wildcard $(patsubst %, $(DEPDIR)/%.d, $(notdir $(basename $(OBJFILES)))))
#include $(patsubst %, $(DEPDIR)/%.d, $(notdir $(basename $(OBJFILES))))
#include $(MYINCLUDES)

test:
	@echo 1 $(OBJFILES)
	@echo 2 $(basename $(OBJFILES))
	@echo 3 $(patsubst %, $(DEPDIR)/%.d, $(basename $(OBJFILES)))
	@echo 4 $(patsubst %, $(DEPDIR)/%.d, $(notdir $(basename $(OBJFILES))))
	@echo 5 $(wildcard $(patsubst %, $(DEPDIR)/%.d, $(basename $(OBJFILES))))
	@echo 6 $(MYINCLUDES)
