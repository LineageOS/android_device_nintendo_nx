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

include device/nvidia/t210-common/vendor/t210-by-flags.mk
include device/nvidia/tegra-common/vendor/common-by-flags.mk

ATF_PATH   := $(abspath hardware/nintendo/arm-trusted-firmware)

# Platform defaults
ATF_PARAMS := PLAT=tegra TARGET_SOC=t210 TZDRAM_BASE=0xFFF00000 RESET_TO_BL31=1 COLD_BOOT_SINGLE_CPU=1 \
                 PROGRAMMABLE_RESET_ADDRESS=1 ENABLE_STACK_PROTECTOR=none

# Not supported in Linux 4.9
ATF_PARAMS += SDEI_SUPPORT=0

# Error reporting
ATF_PARAMS += CRASH_REPORTING=1 ENABLE_ASSERTIONS=1 LOG_LEVEL=0 PLAT_LOG_LEVEL_ASSERT=0

COMMON_BCM_PATH := vendor/nvidia/common/rel-shield-r/bcm
NX_BCM_PATH := vendor/nintendo/nx/rel-shield-r/bcm

PRODUCT_COPY_FILES += \
    $(NX_BCM_PATH)/bcm4356/brcmfmac4356-pcie.clm_blob:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.clm_blob \
    $(NX_BCM_PATH)/bcm4356/brcmfmac4356A3-pcie.txt:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.txt \
    $(NX_BCM_PATH)/bcm4356/CYW4356A3_001.004.009.0092.0095.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/BCM4356A3.hcd

PRODUCT_COPY_FILES += \
    $(COMMON_BCM_PATH)/bcm4356/brcmfmac4356-pcie.bin:$(TARGET_COPY_OUT_VENDOR)/firmware/brcmfmac4356-pcie.bin
