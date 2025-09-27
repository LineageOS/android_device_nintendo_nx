#
# Copyright (C) 2018 The LineageOS Project
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

TARGET_TEGRA_VARIANT    ?= common

TARGET_KERNEL_VERSION ?= 4.9
TARGET_TEGRA_KEYSTORE := software
TARGET_TEGRA_LIGHT    ?= lineage
#TARGET_TEGRA_THERMAL  ?= lineage
TARGET_TEGRA_UBOOT    := prebuilt
TARGET_TEGRA_POWER    := perfmgr

TARGET_ATV_FORCE_1080_SCALING := false

ifneq ($(filter 4.9, $(TARGET_KERNEL_VERSION)),)
TARGET_TEGRA_BT        ?= bcm
TARGET_TEGRA_CAMERA    ?= rel-shield-r
TARGET_TEGRA_CEC      := aosp
TARGET_TEGRA_CPL      := none
TARGET_TEGRA_SENSORS  := iio
TARGET_TEGRA_SENSOR_FEATURES := accelerometer gyroscope light
TARGET_TEGRA_WIDEVINE  ?= rel-shield-r
TARGET_TEGRA_WIFI     ?= bcm
else
TARGET_TEGRA_FIRMWARE_BRANCH ?= linux-firmware
TARGET_AUDIO_HAL := baylibre
TARGET_TV_HDMI_CEC_HAL :=
PRODUCT_COPY_FILES += \
    device/nintendo/nx/initfiles/ack.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/ack.rc \
    device/nintendo/nx/initfiles/init.recovery.ack.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.ack.rc
endif

include device/nvidia/t210-common/t210.mk

# Properties
include device/nintendo/nx/properties.mk

ifeq ($(PRODUCT_IS_ATV),true)
PRODUCT_CHARACTERISTICS   := tv
else
PRODUCT_CHARACTERISTICS   := tablet
endif

PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

$(call inherit-product, frameworks/native/build/tablet-7in-xhdpi-2048-dalvik-heap.mk)

PRODUCT_USE_DYNAMIC_PARTITIONS := true

include device/nintendo/nx/vendor/nx-vendor.mk

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    device/nintendo/nx/overlay/common
ifneq ($(PRODUCT_IS_ATV),true)
DEVICE_PACKAGE_OVERLAYS += \
    device/nintendo/nx/overlay/tablet
endif

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += device/nintendo/nx

# Init related
PRODUCT_PACKAGES += \
    fstab.nx \
    fstab.nx.ramdisk \
    init.fric.rc \
    init.loki_foster_e_common.rc \
    init.nx.rc \
    init.recovery.nx.rc \
    init.sensors.nx.rc \
    init.vali.rc

ifneq ($(filter 4.9 5.10, $(TARGET_KERNEL_VERSION)),)
ifneq ($(TARGET_TEGRA_CPL),none)
PRODUCT_PACKAGES += \
    power.nx.rc
endif
endif

ifeq ($(TARGET_POWER_HAL),perfmgr-lineage)
ifeq ($(TARGET_GRAPHICS),mesa)
PRODUCT_PACKAGES += \
    powerhint.nouveau.json
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.powerhal.config=powerhint.nouveau.json
endif
endif

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml
ifneq ($(PRODUCT_IS_ATV),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.device_admin.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_admin.xml \
    frameworks/native/data/etc/android.software.managed_users.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.managed_users.xml \
    frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
    frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml
endif

# Audio
ifeq ($(TARGET_AUDIO_HAL),baylibre)
PRODUCT_COPY_FILES += \
    device/nvidia/tegra-common/nvaudio/primary_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/primary_audio_policy_configuration.xml
endif

# Bluetooth
ifeq ($(TARGET_TEGRA_BT),bcm)
$(call soong_config_set,brcm_libbt,bdroid_buildcfg_include_dir,device/nintendo/nx/comms)
$(call soong_config_set,brcm_libbt,custom_bt_config,//device/nintendo/nx:vnd_nx.txt)
endif

# CEC
ifneq ($(filter 4.9, $(TARGET_KERNEL_VERSION)),)
PRODUCT_COPY_FILES := $(filter-out frameworks/native/data/etc/android.hardware.hdmi.cec.xml%android.hardware.hdmi.cec.xml,$(PRODUCT_COPY_FILES))

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.hdmi.cec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/staging/android.hardware.hdmi.cec.xml

PRODUCT_PACKAGES += \
    nx_cec.rc \
    cec_disable.xml
endif

# Device Settings
# TEMP
ifneq ($(filter 4.9, $(TARGET_KERNEL_VERSION)),)
PRODUCT_PACKAGES += \
    DeviceSettingsNX
endif

# DocumentsUI
# We are the exception, being an ATV device with touch
PRODUCT_PACKAGES += \
    DocumentsUI

# Fingerprint
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildFingerprint=NVIDIA/nx/nx:11/RQ1A.210105.003/7825230_4040.2147:user/release-keys

# GMS
ifeq ($(WITH_GMS),true)
WITH_GMS_COMMS_SUITE := false
endif

# Input
PRODUCT_PACKAGES += \
    excluded-input-devices.xml

ifneq ($(filter 4.9, $(TARGET_KERNEL_VERSION)),)
# Joycons
PRODUCT_PACKAGES += \
    android.hardware.nintendo.joycond-service \
    jc_setup
endif

# Kernel Modules
ifneq ($(filter 4.9, $(TARGET_KERNEL_VERSION)),)
PRODUCT_PACKAGES += \
    cypress-fmac-upstream
endif

# Keylayouts
PRODUCT_PACKAGES += \
    gpio-keys.kl

# Loadable kernel modules
PRODUCT_PACKAGES += \
    lkm_loader

PRODUCT_COPY_FILES += \
    device/nvidia/tegra-common/initfiles/init.lkm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.lkm.rc
ifneq ($(filter 4.9, $(TARGET_KERNEL_VERSION)),)
PRODUCT_PACKAGES += \
    lkm_loader_target
else
PRODUCT_COPY_FILES += \
    device/nintendo/nx/initfiles/lkm.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/lkm.rc
endif

# Partitions
$(call inherit-product, $(SRC_TARGET_DIR)/product/non_ab_device.mk)

# PHS
ifneq ($(TARGET_TEGRA_PHS),)
PRODUCT_PACKAGES += \
    nvphsd.conf
endif

# Recovery
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += persist.vendor.recovery_update=true

# Shipping API
ifneq ($(filter 4.9 5.10, $(TARGET_KERNEL_VERSION)),)
PRODUCT_COPY_FILES += \
    system/core/libprocessgroup/profiles/cgroups_28.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json \
    system/core/libprocessgroup/profiles/task_profiles_28.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json

$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_l.mk)
else
PRODUCT_SHIPPING_API_LEVEL := 36
endif

# Thermal
ifneq ($(TARGET_TEGRA_THERMAL),)
ifneq ($(filter 4.9 5.10, $(TARGET_KERNEL_VERSION)),)
PRODUCT_COPY_FILES += \
    device/nintendo/nx/thermal/thermalhal.nx.xml:$(TARGET_COPY_OUT_VENDOR)/etc/thermalhal.nx.xml
else
PRODUCT_COPY_FILES += \
    device/nintendo/nx/thermal/thermalhal.nx.ack.xml:$(TARGET_COPY_OUT_VENDOR)/etc/thermalhal.nx.xml
endif
endif

# WiFi
PRODUCT_PACKAGES += \
    WifiOverlay
