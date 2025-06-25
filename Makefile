# Makefile for ec_su_axb35

BUILD_DIR ?= build
KERNEL_BUILD ?= /lib/modules/$(shell uname -r)/build
KERNEL_MODULES_DIR := /lib/modules/$(shell uname -r)/extra

all: prepare
	$(MAKE) -C $(KERNEL_BUILD) M=$(PWD)/$(BUILD_DIR) modules
	@echo "Cleaning temporary build files..."
	rm -f $(PWD)/$(BUILD_DIR)/ec_su_axb35.c
	rm -f $(PWD)/$(BUILD_DIR)/Makefile

prepare: $(BUILD_DIR)
	cp -f $(PWD)/src/ec_su_axb35.c $(PWD)/$(BUILD_DIR)/
	@echo 'obj-m := ec_su_axb35.o' > $(PWD)/$(BUILD_DIR)/Makefile

clean:
	rm -rf $(BUILD_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

install: all
	mkdir -p $(KERNEL_MODULES_DIR)
	cp -v $(BUILD_DIR)/ec_su_axb35.ko $(KERNEL_MODULES_DIR)/
	depmod