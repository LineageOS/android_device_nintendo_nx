#
# Copyright (C) 2022-2024 The LineageOS Project
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

BOARD_FLASH_BLOCK_SIZE                 := 4096
BOARD_BOOTIMAGE_PARTITION_SIZE         := 67108864
BOARD_RECOVERYIMAGE_PARTITION_SIZE     := 67108864
BOARD_CACHEIMAGE_PARTITION_SIZE        := 63963136
TARGET_USERIMAGES_USE_EXT4             := true
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE        := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE    := ext4
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE      := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE     := ext4
TARGET_COPY_OUT_SYSTEM_EXT             := system_ext
TARGET_COPY_OUT_ODM                    := odm
TARGET_COPY_OUT_PRODUCT                := product
TARGET_COPY_OUT_VENDOR                 := vendor

-include vendor/lineage/config/BoardConfigReservedSize.mk

BOARD_NVIDIA_DYNAMIC_PARTITIONS_PARTITION_LIST := product system system_ext vendor odm
BOARD_NVIDIA_DYNAMIC_PARTITIONS_SIZE           := 6169821184
BOARD_SUPER_PARTITION_GROUPS                   := nvidia_dynamic_partitions
BOARD_SUPER_PARTITION_SIZE                     := 6178209792

# Assert
TARGET_OTA_ASSERT_DEVICE := nx,nx_tab

# Bootloader versions
TARGET_BOARD_INFO_FILE := device/nintendo/nx/board-info.txt

# Manifest
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += device/nintendo/nx/manifests/device_framework_matrix.xml

# Bluetooth
TARGET_VENDOR_PROP += device/nintendo/nx/bluetooth.prop

# Charger
WITH_LINEAGE_CHARGER := false

# DPI
TARGET_SCREEN_DENSITY := 186

# Kernel Source
KERNEL_TOOLCHAIN               := $(shell pwd)/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-gnu-9.3/bin
KERNEL_TOOLCHAIN_PREFIX        := aarch64-buildroot-linux-gnu-
TARGET_KERNEL_CLANG_COMPILE    := false
TARGET_KERNEL_SOURCE           := kernel/nvidia/kernel-$(TARGET_KERNEL_VERSION)-nx
TARGET_KERNEL_CONFIG           := tegra_android_defconfig
TARGET_KERNEL_ADDITIONAL_FLAGS := \
    NV_BUILD_KERNEL_OPTIONS=$(TARGET_KERNEL_VERSION) \
    HOSTCFLAGS="-fuse-ld=lld -Wno-unused-command-line-argument" \
    CONFIG_EXFAT_FS=m

TARGET_KERNEL_EXT_MODULE_ROOT := kernel/nvidia
TARGET_KERNEL_EXT_MODULES := \
    exfat:kbuild \
    nvgpu/drivers/gpu/nvgpu:kbuild
include device/nintendo/nx/modules.mk

# Kernel Image Parameters
BOARD_KERNEL_IMAGE_NAME        := Image.gz
BOARD_MKBOOTIMG_ARGS           := \
    --base 0x80000000 \
    --kernel_offset 0x200000 \
    --ramdisk_offset 0x4000000

# Recovery
TARGET_RECOVERY_DENSITY      := hdpi
TARGET_RECOVERY_FSTAB        := device/nintendo/nx/initfiles/fstab.nx
TARGET_RECOVERY_UPDATER_LIBS := librecoveryupdater_tegra
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := device/nintendo/nx/releasetools

# Security Patch Level
VENDOR_SECURITY_PATCH := 2024-12-05

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += device/nintendo/nx/sepolicy/vendor
SELINUX_IGNORE_NEVERALLOWS := true

# Include Joycond sepolicy if present
-include hardware/nintendo/joycond/joycond-sepolicy.mk

# Treble
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true
BOARD_VNDK_VERSION                     := current
PRODUCT_FULL_TREBLE_OVERRIDE           := true

# Updater
AB_OTA_UPDATER := false

# Verity
# Only needed for signing
BOARD_AVB_ENABLE := false

# Wi-Fi
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
WIFI_AVOID_IFACE_RESET_MAC_CHANGE := true

include device/nvidia/t210-common/BoardConfigCommon.mk
