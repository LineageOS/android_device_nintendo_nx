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

LOCAL_PATH := device/nintendo/nx/vendor/bcm_firmware
COMMON_BCM_PATH := device/nvidia/tegra-common/vendor/bcm_firmware

$(call inherit-product, $(COMMON_BCM_PATH)/bcm4354/device-bcm.mk)

PRODUCT_PACKAGES += \
    bcm4356 \
    brcmfmac4356-pcie \
    brcmfmac4356-pcie.clm_blob \
    BCM4356A3
