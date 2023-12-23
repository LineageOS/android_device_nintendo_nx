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

include device/nvidia/t210-common/vendor/t210.mk
include device/nvidia/tegra-common/vendor/common-by-flags.mk
include device/nintendo/nx/vendor/bcm_firmware/bcm.mk

PRODUCT_PACKAGES += public.libraries

ATF_PATH   := $(BUILD_TOP)/hardware/nintendo/arm-trusted-firmware

# Platform defaults
ATF_PARAMS := PLAT=tegra TARGET_SOC=t210 TZDRAM_BASE=0xFFF00000 RESET_TO_BL31=1 COLD_BOOT_SINGLE_CPU=1 \
                 PROGRAMMABLE_RESET_ADDRESS=1 ENABLE_STACK_PROTECTOR=none

# Not supported in Linux 4.9
ATF_PARAMS += SDEI_SUPPORT=0

# Error reporting
ATF_PARAMS += CRASH_REPORTING=1 ENABLE_ASSERTIONS=1 LOG_LEVEL=0 PLAT_LOG_LEVEL_ASSERT=0

# Switch firmware files
PRODUCT_PACKAGES += \
	android.ini \
	bootlogo_android \
	icon_android_hue \
	bl31 \
	bl33

INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bl31.bin
