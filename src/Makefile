####################
#  HELLO-WORLD-OS  #
####################

export ASSEMBLER = as
export COMPILER = gcc
export LINKER = ld

export OS_TARGET = HelloWorldOS

export BOOT_TARGET = boot.bin
export KERNEL_TARGET = kernel.bin

export BINDIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/../bin

SUBDIRS := boot kernel


#####################
#        ALL        #
#####################

.PHONY: all
all:  $(SUBDIRS) $(OS_TARGET)

$(OS_TARGET):
	touch $(BINDIR)/$(OS_TARGET)
	dd if=/dev/zero of=$(BINDIR)/$(OS_TARGET) bs=512 count=32
	dd if=$(BINDIR)/$(BOOT_TARGET) of=$(BINDIR)/$(OS_TARGET) bs=512 count=1 conv=notrunc
	dd if=$(BINDIR)/$(KERNEL_TARGET) of=$(BINDIR)/$(OS_TARGET) bs=512 count=31 obs=512 seek=1 conv=notrunc

$(SUBDIRS):
	$(MAKE) -C $@


#####################
#       TEST        #
#####################

.PHONY: test
test:
	qemu-system-i386 -drive file=$(BINDIR)/$(OS_TARGET),index=0,if=ide,format=raw


#####################
#       CLEAN       #
#####################

.PHONY: clean
clean:
	rm -f $(BINDIR)/*
