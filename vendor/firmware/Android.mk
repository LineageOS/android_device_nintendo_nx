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

LOCAL_PATH := $(call my-dir)

UBOOT_PATH := $(BUILD_TOP)/hardware/nintendo/u-boot
NX_FW_PATH := vendor/nintendo/nx/rel-shield-r/

BUILD_TOOLS_BINS         := $(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin
LINEAGE_TOOLS_PATH       := $(BUILD_TOP)/prebuilts/tools-lineage/$(HOST_PREBUILT_TAG)/bin
TARGET_KERNEL_CLANG_PATH ?= $(BUILD_TOP)/prebuilts/clang/host/$(HOST_PREBUILT_TAG)/$(LLVM_PREBUILTS_VERSION)

# U-Boot
include $(CLEAR_VARS)
LOCAL_MODULE        := bl33
LOCAL_MODULE_SUFFIX := .bin
LOCAL_MODULE_CLASS  := EXECUTABLES
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)

ifeq ($(TARGET_TEGRA_UBOOT),prebuilt)
LOCAL_SRC_FILES        := ../../../../../$(NX_FW_PATH)/bl33.bin
LOCAL_REQUITED_MODULES := boot.scr
include $(BUILD_PREBUILT)
else # TARGET_TEGRA_UBOOT
_uboot_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_uboot_bin := $(_uboot_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_uboot_bin): $(sort $(shell find -L $(UBOOT_PATH)))
	@mkdir -p $(dir $@)
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_CROSS_COMPILE) \
		HOSTCC=$(TARGET_KERNEL_CLANG_PATH)/bin/clang HOSTLDFLAGS="-fuse-ld=lld" \
		YACC=$(BUILD_TOOLS_BINS)/bison LEX=$(BUILD_TOOLS_BINS)/flex M4=$(BUILD_TOOLS_BINS)/m4 \
		-C $(UBOOT_PATH) O=$(abspath $(_uboot_intermediates)) nx_defconfig
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_CROSS_COMPILE) \
		HOSTCC=$(TARGET_KERNEL_CLANG_PATH)/bin/clang HOSTLDFLAGS="-fuse-ld=lld" \
		YACC=$(BUILD_TOOLS_BINS)/bison LEX=$(BUILD_TOOLS_BINS)/flex M4=$(BUILD_TOOLS_BINS)/m4 \
		-C $(UBOOT_PATH) O=$(abspath $(_uboot_intermediates)) u-boot-dtb.bin
	@mv $(_uboot_intermediates)/u-boot-dtb.bin $(_uboot_bin)

include $(BUILD_SYSTEM)/base_rules.mk
endif # TARGET_TEGRA_UBOOT

INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bl33.bin
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bl31.bin
