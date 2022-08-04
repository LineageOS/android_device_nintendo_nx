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
LINEAGE_TOOLS_PATH := $(abspath prebuilts/tools-lineage/$(HOST_PREBUILT_TAG)/bin)
NX_VENDOR_PATH := ../../../../../vendor/nintendo

include $(CLEAR_VARS)
LOCAL_MODULE               := reboot_payload
LOCAL_SRC_FILES            := $(NX_VENDOR_PATH)/bootloader/hekate.bin
LOCAL_MODULE_SUFFIX        := .bin
LOCAL_MODULE_CLASS         := ETC
LOCAL_MODULE_PATH          := $(TARGET_OUT_VENDOR)/firmware/
LOCAL_MODULE_TAGS          := optional
LOCAL_MODULE_OWNER         := nvidia
include $(BUILD_NVIDIA_PREBUILT)

# Uscript
include $(CLEAR_VARS)
LOCAL_MODULE        := boot.scr
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)

_uscript_input := $(abspath vendor/nintendo/bootfiles/android_boot.txt)
_uscript_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_uscript_archive := $(_uscript_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_uscript_archive):
	@mkdir -p $(dir $@)
	$(LINEAGE_TOOLS_PATH)/mkimage -A arm -T script -O linux -d $(_uscript_input) $(_uscript_intermediates)/boot.scr

include $(BUILD_SYSTEM)/base_rules.mk
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/boot.scr

include $(CLEAR_VARS)
LOCAL_MODULE        := coreboot
LOCAL_MODULE_SUFFIX := .rom
LOCAL_SRC_FILES     := $(NX_VENDOR_PATH)/bootfiles/coreboot.rom
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)
include $(BUILD_PREBUILT)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/coreboot.rom

# Config
include $(CLEAR_VARS)
LOCAL_MODULE        := 00-android
LOCAL_MODULE_SUFFIX := .ini
LOCAL_SRC_FILES     := $(NX_VENDOR_PATH)/config/00-android.ini
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)
include $(BUILD_PREBUILT)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/00-android.ini

include $(CLEAR_VARS)
LOCAL_MODULE        := bootlogo_android
LOCAL_MODULE_SUFFIX := .bmp
LOCAL_SRC_FILES     := $(NX_VENDOR_PATH)/config/bootlogo_android.bmp
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)
include $(BUILD_PREBUILT)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bootlogo_android.bmp

include $(CLEAR_VARS)
LOCAL_MODULE        := icon_android_hue
LOCAL_MODULE_SUFFIX := .bmp
LOCAL_SRC_FILES     := $(NX_VENDOR_PATH)/config/icon_android_hue.bmp
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)
include $(BUILD_PREBUILT)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/icon_android_hue.bmp
