# Copyright (C) 2022 The LineageOS Project
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
NX_VENDOR_PATH := ../../../../../vendor/nintendo

ATF_PATH   := $(BUILD_TOP)/external/switch-atf
UBOOT_PATH := $(BUILD_TOP)/external/switch-uboot

BUILD_TOOLS_BINS         := $(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin
LINEAGE_TOOLS_PATH       := $(BUILD_TOP)/prebuilts/tools-lineage/$(HOST_PREBUILT_TAG)/bin
TARGET_KERNEL_CLANG_PATH ?= $(BUILD_TOP)/prebuilts/clang/host/$(HOST_PREBUILT_TAG)/$(LLVM_PREBUILTS_VERSION)

# Platform defaults
BL31_MAKEARGS := PLAT=tegra TARGET_SOC=t210 TZDRAM_BASE=0xFFF00000 RESET_TO_BL31=1 COLD_BOOT_SINGLE_CPU=1 \
                 PROGRAMMABLE_RESET_ADDRESS=1 ENABLE_STACK_PROTECTOR=none

# Not supported in Linux 4.9
BL31_MAKEARGS += SDEI_SUPPORT=0

# Error reporting
BL31_MAKEARGS += CRASH_REPORTING=1 ENABLE_ASSERTIONS=1 LOG_LEVEL=0 PLAT_LOG_LEVEL_ASSERT=0

# ATF
include $(CLEAR_VARS)
LOCAL_MODULE        := bl31
LOCAL_MODULE_SUFFIX := .bin
LOCAL_MODULE_CLASS  := EXECUTABLES
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)

_atf_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_atf_bin := $(_atf_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_atf_bin):
	@mkdir -p $(dir $@)
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_CROSS_COMPILE) \
	CLANG_CCDIR=$(TARGET_KERNEL_CLANG_PATH)/bin/ CC=$(TARGET_KERNEL_CLANG_PATH)/bin/clang -C $(ATF_PATH) \
	BUILD_BASE=$(abspath $(_atf_intermediates)) $(BL31_MAKEARGS) bl31
	@cp $(dir $@)/tegra/t210/release/bl31.bin $@

include $(BUILD_SYSTEM)/base_rules.mk
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bl31.bin

# U-Boot
include $(CLEAR_VARS)
LOCAL_MODULE        := bl33
LOCAL_MODULE_SUFFIX := .bin
LOCAL_MODULE_CLASS  := EXECUTABLES
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)

_uboot_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_uboot_bin := $(_uboot_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_uboot_bin):
	@mkdir -p $(dir $@)
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_CROSS_COMPILE) \
		HOSTCC=$(TARGET_KERNEL_CLANG_PATH)/bin/clang HOSTLDFLAGS="-fuse-ld=lld" \
		YACC=$(BUILD_TOOLS_BINS)/bison LEX=$(BUILD_TOOLS_BINS)/flex M4=$(BUILD_TOOLS_BINS)/m4 \
		-C $(UBOOT_PATH) O=$(abspath $(_uboot_intermediates)) $(TARGET_TEGRA_UBOOT)_defconfig
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_CROSS_COMPILE) \
		HOSTCC=$(TARGET_KERNEL_CLANG_PATH)/bin/clang HOSTLDFLAGS="-fuse-ld=lld" \
		YACC=$(BUILD_TOOLS_BINS)/bison LEX=$(BUILD_TOOLS_BINS)/flex M4=$(BUILD_TOOLS_BINS)/m4 \
		-C $(UBOOT_PATH) O=$(abspath $(_uboot_intermediates)) u-boot-dtb.bin
	@mv $(_uboot_intermediates)/u-boot-dtb.bin $(_uboot_bin)

include $(BUILD_SYSTEM)/base_rules.mk
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bl33.bin
