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

NX_BOOTFILES_PATH := $(BUILD_TOP)/device/nintendo/nx/bootfiles
NX_FIRMWARE_PATH := $(BUILD_TOP)/vendor/nintendo/nx/external/u-boot

_uscript_input := $(abspath $(NX_BOOTFILES_PATH)/android_boot.txt)
_uscript_archive := $(call intermediates-dir-for,EXECUTABLES,boot.scr)/boot.scr
$(_uscript_archive): $(_uscript_input)
	@mkdir -p $(dir $@)
	$(LINEAGE_TOOLS_PATH)/bin/mkimage -A arm -T script -O linux -d $(_uscript_input) $@

$(PRODUCT_OUT)/boot.scr: $(_uscript_archive)
	$(hide) cp $< $@
.PHONY: boot.scr
boot.scr: $(PRODUCT_OUT)/boot.scr

BUILT_TARGET_FILES_ZIPROOT := $(call intermediates-dir-for,PACKAGING,target_files)/$(TARGET_PRODUCT)-target_files
$(BUILT_TARGET_FILES_ZIPROOT).zip: $(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/bl31.bin $(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/boot.scr

$(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/bl31.bin: $(BUILT_TARGET_FILES_ZIPROOT).zip.list $(PRODUCT_OUT)/bl31.bin
	@mkdir -p $(dir $@)
	@cp $(PRODUCT_OUT)/bl31.bin $@
	@echo $@ >> $(BUILT_TARGET_FILES_ZIPROOT).zip.list

$(BUILT_TARGET_FILES_ZIPROOT)/IMAGES/boot.scr: $(BUILT_TARGET_FILES_ZIPROOT).zip.list $(PRODUCT_OUT)/boot.scr
	@mkdir -p $(dir $@)
	@cp $(PRODUCT_OUT)/boot.scr $@
	@echo $@ >> $(BUILT_TARGET_FILES_ZIPROOT).zip.list


INSTALLED_RADIOIMAGE_TARGET += $(NX_BOOTFILES_PATH)/android.ini
INSTALLED_RADIOIMAGE_TARGET += $(NX_BOOTFILES_PATH)/bootlogo_android.bmp
INSTALLED_RADIOIMAGE_TARGET += $(NX_BOOTFILES_PATH)/icon_android_hue.bmp
INSTALLED_RADIOIMAGE_TARGET += $(NX_FIRMWARE_PATH)/bl33.bin
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/boot.scr
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bl31.bin

endif # TARGET_DEVICE
