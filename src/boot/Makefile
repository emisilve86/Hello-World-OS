####################
#  HELLO-WORLD-OS  #
####################

ASSEMBLER ?= as
LINKER ?= ld

BINDIR ?= .

BOOT_TARGET ?= boot.bin

BOOT_LINKER_SCRIPT := boot.ld

BOOT_SRCS := boot.o
BOOT_OBJS := $(filter %.o,$(patsubst %.S,%.o,$(BOOT_SRCS)))

SUBDIRS :=


#####################
#        ALL        #
#####################

.PHONY: all
all: $(SUBDIRS) $(BOOT_TARGET)

$(BOOT_TARGET): $(BOOT_OBJS)
	$(LINKER) -m elf_i386 -T $(BOOT_LINKER_SCRIPT) --oformat binary $(addprefix $(BINDIR)/,$^) -o $(BINDIR)/$@

$(SUBDIRS):
	$(MAKE) -C $@

%.o: %.S
	$(ASSEMBLER) --32 $< -o $(BINDIR)/$@
