# Copyright (C) 2023 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ifneq ($(filter nx nx_tab,$(TARGET_DEVICE)),)

UBOOT_PATH := $(BUILD_TOP)/hardware/nintendo/u-boot
NX_FW_PATH := vendor/nintendo/nx/rel-shield-r

BUILD_TOOLS_BINS         := $(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin
LINEAGE_TOOLS_PATH       := $(BUILD_TOP)/prebuilts/tools-lineage/$(HOST_PREBUILT_TAG)/bin
TARGET_KERNEL_CLANG_PATH ?= $(BUILD_TOP)/prebuilts/clang/host/$(HOST_PREBUILT_TAG)/$(LLVM_PREBUILTS_VERSION)

ifneq ($(TARGET_TEGRA_UBOOT),prebuilt)

_uboot_bin := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_uboot_bin := $(_uboot_bin)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_uboot_bin): $(sort $(shell find -L $(UBOOT_PATH)))
	@mkdir -p $(dir $@)
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_CROSS_COMPILE) \
		HOSTCC=$(TARGET_KERNEL_CLANG_PATH)/bin/clang HOSTLDFLAGS="-fuse-ld=lld" \
		YACC=$(BUILD_TOOLS_BINS)/bison LEX=$(BUILD_TOOLS_BINS)/flex M4=$(BUILD_TOOLS_BINS)/m4 \
		-C $(UBOOT_PATH) O=$(dir $(_uboot_bin)) nx_defconfig
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_CROSS_COMPILE) \
		HOSTCC=$(TARGET_KERNEL_CLANG_PATH)/bin/clang HOSTLDFLAGS="-fuse-ld=lld" \
		YACC=$(BUILD_TOOLS_BINS)/bison LEX=$(BUILD_TOOLS_BINS)/flex M4=$(BUILD_TOOLS_BINS)/m4 \
		-C $(UBOOT_PATH) O=$(dir $(_uboot_bin)) bl33.bin
	@mv $(_uboot_bin)/bl33.bin $(_uboot_bin)

$(PRODUCT_OUT)/bl33.bin: $(_uboot_bin)
	$(hide) cp $< $@
.PHONY: bl33
u-boot-dtb: $(PRODUCT_OUT)/bl33.bin
endif # TARGET_TEGRA_UBOOT

_uscript_input := $(abspath device/nintendo/nx/bootfiles/android_boot.txt)
_uscript_archive := $(call intermediates-dir-for,EXECUTABLES,boot.scr)
$(_uscript_archive): $(_uscript_input)
	@mkdir -p $(dir $@)
	$(LINEAGE_TOOLS_PATH)/mkimage -A arm -T script -O linux -d $(_uscript_input) $(_uscript_archive)/boot.scr

$(PRODUCT_OUT)/boot.scr: $(_uscript_archive)
	$(hide) cp $< $@
.PHONY: boot.scr
boot.scr: $(PRODUCT_OUT)/boot.scr

endif # TARGET_DEVICE
