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
FOSTER_BCM_PATH := ../../../../../vendor/nvidia/foster/bcm_firmware
NX_BCM_PATH := ../../../../../vendor/nintendo/bcm_firmware

include $(CLEAR_VARS)
LOCAL_MODULE        := BCM4356A3
LOCAL_SRC_FILES     := $(NX_BCM_PATH)/CYW4356A3_001.004.009.0092.0095.bin
LOCAL_MODULE_SUFFIX := .hcd
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/firmware/brcm
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_OWNER  := nintendo
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := brcmfmac4356A3-pcie.bin
LOCAL_MODULE_CLASS         := ETC
LOCAL_MODULE_PATH          := $(TARGET_OUT_VENDOR)

_brcmfmac4356A3_input         := $(BUILD_TOP)/vendor/nintendo/bcm_firmware/brcmfmac4356A3-pcie.bin
_brcmfmac4356A3_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_brcmfmac4356A3_archive       := $(_brcmfmac4356A3_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)

$(_brcmfmac4356A3_archive):
	@mkdir -p $(dir $@)
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware
	cp $(_brcmfmac4356A3_input) $(_brcmfmac4356A3_intermediates)
	cp $(_brcmfmac4356A3_input) $(TARGET_OUT_VENDOR)/firmware/brcmfmac4356-pcie.bin

LOCAL_MODULE_TAGS          := optional
LOCAL_MODULE_OWNER         := nintendo
include $(BUILD_SYSTEM)/base_rules.mk

include $(CLEAR_VARS)
LOCAL_MODULE               := brcmfmac4356-pcie.nintendo,icosa.txt
LOCAL_SRC_FILES            := $(NX_BCM_PATH)/brcmfmac4356A3-pcie.txt
LOCAL_MODULE_CLASS         := ETC
LOCAL_MODULE_PATH          := $(TARGET_OUT_VENDOR)/firmware
LOCAL_MODULE_TAGS          := optional
LOCAL_MODULE_OWNER         := nintendo
include $(BUILD_PREBUILT)
