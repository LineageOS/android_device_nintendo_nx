# Copyright (C) 2020-2024 The LineageOS Project
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
NX_BCM_PATH := vendor/nintendo/nx/rel-shield-r/bcm_firmware/bcm4356

# Bluetooth Patchfile
include $(CLEAR_VARS)
LOCAL_MODULE        := BCM4356A3
LOCAL_SRC_FILES     := ../../../../../$(NX_BCM_PATH)/CYW4356A3_001.004.009.0092.0095.bin
LOCAL_MODULE_SUFFIX := .hcd
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/firmware
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_OWNER  := nintendo
include $(BUILD_PREBUILT)

# WiFi NVRAM copies per-sku
include $(CLEAR_VARS)
LOCAL_MODULE        := brcmfmac4356-pcie.nvidia,odin.txt
LOCAL_SRC_FILES     := ../../../../../$(NX_BCM_PATH)/brcmfmac4356A3-pcie.txt
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/firmware
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_OWNER  := nintendo
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := brcmfmac4356-pcie.nvidia,modin.txt
LOCAL_SRC_FILES     := ../../../../../$(NX_BCM_PATH)/brcmfmac4356A3-pcie.txt
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/firmware
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_OWNER  := nintendo
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := brcmfmac4356-pcie.nvidia,vali.txt
LOCAL_SRC_FILES     := ../../../../../$(NX_BCM_PATH)/brcmfmac4356A3-pcie.txt
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/firmware
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_OWNER  := nintendo
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := brcmfmac4356-pcie.nvidia,fric.txt
LOCAL_SRC_FILES     := ../../../../../$(NX_BCM_PATH)/brcmfmac4356A3-pcie.txt
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/firmware
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_OWNER  := nintendo
include $(BUILD_PREBUILT)

# mdarcy clm target
include $(CLEAR_VARS)
LOCAL_MODULE        := brcmfmac4356-pcie.clm_blob
LOCAL_SRC_FILES     := ../../../../../$(NX_BCM_PATH)/brcmfmac4356-pcie.clm_blob
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/firmware
LOCAL_MODULE_TAGS   := optional
LOCAL_MODULE_OWNER  := nintendo
include $(BUILD_PREBUILT)
