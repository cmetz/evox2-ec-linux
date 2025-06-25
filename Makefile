# Makefile for ec_su_axb35

KERNEL_BUILD ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KERNEL_BUILD) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_BUILD) M=$(PWD) clean
	rm -rf $(BUILD_DIR)

install: all
	$(MAKE) -C $(KERNEL_BUILD) M=$(PWD) modules_install
	depmod
