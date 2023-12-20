#
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
#

BOARD_FLASH_BLOCK_SIZE             := 4096
BOARD_BOOTIMAGE_PARTITION_SIZE     := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_CACHEIMAGE_PARTITION_SIZE    := 734003200
BOARD_USERDATAIMAGE_PARTITION_SIZE := 10099646976
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 2147483648
BOARD_VENDORIMAGE_PARTITION_SIZE   := 1073741824
TARGET_USERIMAGES_USE_EXT4         := true
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE  := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR             := vendor
BOARD_BUILD_SYSTEM_ROOT_IMAGE      := true
BOARD_USES_METADATA_PARTITION      := true

# Assert
TARGET_OTA_ASSERT_DEVICE := nx,nx_tab

# Bootloader versions
TARGET_BOARD_INFO_FILE := device/nintendo/nx/board-info.txt

# Manifest
DEVICE_MANIFEST_FILE := device/nintendo/nx/manifest.xml

# Bluetooth
TARGET_VENDOR_PROP += device/nintendo/nx/bluetooth.prop
BOARD_CUSTOM_BT_CONFIG := device/nintendo/nx/comms/vnd_nx.txt
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/nintendo/nx/comms

# Charger
WITH_LINEAGE_CHARGER := false

# Kernel Source
KERNEL_TOOLCHAIN               := $(shell pwd)/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-gnu-9.3/bin
KERNEL_TOOLCHAIN_PREFIX        := aarch64-buildroot-linux-gnu-
TARGET_KERNEL_CLANG_COMPILE    := false
TARGET_KERNEL_SOURCE           := kernel/nvidia/kernel-$(TARGET_TEGRA_KERNEL)-nx
TARGET_KERNEL_CONFIG           := tegra_android_defconfig
TARGET_KERNEL_ADDITIONAL_FLAGS := \
    NV_BUILD_KERNEL_OPTIONS=$(TARGET_TEGRA_KERNEL)
    HOSTCFLAGS="-fuse-ld=lld -Wno-unused-command-line-argument"
include device/nintendo/nx/modules.mk

# Kernel Image Parameters
BOARD_KERNEL_IMAGE_NAME        := Image.gz
BOARD_KERNEL_LOAD_BASE         := 0x88000000
BOARD_MKBOOTIMG_ARGS           := --base $(BOARD_KERNEL_LOAD_BASE)

# Recovery
TARGET_RECOVERY_DENSITY      := hdpi
TARGET_RECOVERY_FSTAB        := device/nintendo/nx/initfiles/fstab.nx
TARGET_RECOVERY_UPDATER_LIBS := librecoveryupdater_tegra
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := device/nintendo/nx/releasetools

# Security Patch Level
VENDOR_SECURITY_PATCH := 2022-04-05

# Treble
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
BOARD_VNDK_VERSION                     := current
PRODUCT_FULL_TREBLE_OVERRIDE           := true

# Verity
# Only needed for signing
BOARD_AVB_ENABLE := false

include device/nvidia/t210-common/BoardConfigCommon.mk
