# Makefile for ec_su_axb35

KERNEL_BUILD ?= /lib/modules/$(shell uname -r)/build
MODULE_NAME := ec_su_axb35.ko
MODULE_INSTALLED_PATH := $(shell modinfo -n $(basename $(MODULE_NAME)) 2>/dev/null)

all:
	$(MAKE) -C $(KERNEL_BUILD) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_BUILD) M=$(PWD) clean
	rm -rf $(BUILD_DIR)

install: all
	$(MAKE) -C $(KERNEL_BUILD) M=$(PWD) modules_install
	depmod

uninstall:
	@if [ -n "$(MODULE_INSTALLED_PATH)" ]; then \
		echo "Removing $(MODULE_INSTALLED_PATH)"; \
		rm -v "$(MODULE_INSTALLED_PATH)"; \
		depmod; \
	else \
		echo "Module not found."; \
	fi

