####################
#  HELLO-WORLD-OS  #
####################

ASSEMBLER ?= as
COMPILER ?= gcc
LINKER ?= ld

BINDIR ?= .

KERNEL_TARGET ?= kernel.bin

KERNEL_LINKER_SCRIPT := kernel.ld

KERNEL_SRCS := kentry.S kernel.c video.c
KERNEL_OBJS := $(filter %.o,$(patsubst %.S,%.o,$(KERNEL_SRCS)))
KERNEL_OBJS += $(filter %.o,$(patsubst %.c,%.o,$(KERNEL_SRCS)))

SUBDIRS :=


#####################
#        ALL        #
#####################

.PHONY: all
all: $(SUBDIRS) $(KERNEL_TARGET)

$(KERNEL_TARGET): $(KERNEL_OBJS)
	$(LINKER) -m elf_i386 -T $(KERNEL_LINKER_SCRIPT) --oformat binary $(addprefix $(BINDIR)/,$^) -o $(BINDIR)/$@

$(SUBDIRS):
	$(MAKE) -C $@

%.o: %.S
	$(ASSEMBLER) --32 $< -o $(BINDIR)/$@

%.o: %.c
	$(COMPILER) -m32 -fno-pie -ffreestanding -c $< -o $(BINDIR)/$@
