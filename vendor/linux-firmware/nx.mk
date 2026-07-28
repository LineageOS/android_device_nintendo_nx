# Copyright (C) 2026 The LineageOS Project
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

LOCAL_PATH := device/nintendo/nx/vendor/linux-firmware
PRODUCT_SOONG_NAMESPACES += $(LOCAL_PATH)

COMMON_BCM_PATH := vendor/nvidia/common/rel-shield-r/bcm
NX_BCM_PATH := vendor/nintendo/nx/rel-shield-r/bcm
NX_BCM_EXTERNAL_PATH := vendor/nintendo/nx/external/bcm

include device/nvidia/tegra-common/vendor/$(TARGET_TEGRA_FIRMWARE_BRANCH)/bcm/bcm4356.mk

PRODUCT_COPY_FILES += \
    $(NX_BCM_PATH)/bcm4356/brcmfmac4356-pcie.clm_blob:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.clm_blob \
    $(NX_BCM_EXTERNAL_PATH)/bcm4356/brcmfmac4356A3-pcie.txt:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.nvidia,odin.txt \
    $(NX_BCM_EXTERNAL_PATH)/bcm4356/brcmfmac4356A3-pcie.txt:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.nvidia,modin.txt \
    $(NX_BCM_EXTERNAL_PATH)/bcm4356/brcmfmac4356A3-pcie.txt:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.nvidia,vali.txt \
    $(NX_BCM_EXTERNAL_PATH)/bcm4356/brcmfmac4356A3-pcie.txt:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.nvidia,fric.txt \
    $(NX_BCM_EXTERNAL_PATH)/bcm4356/CYW4356A3_001.004.009.0092.0095.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/BCM4356A3.hcd

PRODUCT_COPY_FILES += \
    $(COMMON_BCM_PATH)/bcm4356/brcmfmac4356-pcie.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.bin
