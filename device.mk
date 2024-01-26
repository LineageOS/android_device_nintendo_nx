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

TARGET_TEGRA_AUDIO    ?= nvaudio
TARGET_TEGRA_BT       ?= bcm
TARGET_TEGRA_CEC      ?= aosp
TARGET_TEGRA_KERNEL   ?= 4.9
TARGET_TEGRA_KEYSTORE := software
TARGET_TEGRA_MEMTRACK ?= nvmemtrack
TARGET_TEGRA_OMX      ?= nvmm
TARGET_TEGRA_PHS      ?= nvphs
TARGET_TEGRA_POWER    ?= aosp
TARGET_TEGRA_WIDEVINE ?= true
TARGET_TEGRA_WIFI     ?= bcm

TARGET_TEGRA_WIREGUARD ?= compat

include device/nvidia/t210-common/t210.mk

# Properties
include $(LOCAL_PATH)/properties.mk

PRODUCT_AAPT_PREBUILT_DPI := xxhdpi xhdpi hdpi tvdpi mdpi
PRODUCT_AAPT_CONFIG := normal large xlarge
ifeq ($(PRODUCT_IS_ATV),true)
PRODUCT_CHARACTERISTICS   := tv
PRODUCT_AAPT_PREF_CONFIG  := tvdpi
else
PRODUCT_CHARACTERISTICS   := tablet
PRODUCT_AAPT_PREF_CONFIG  := xhdpi
endif

$(call inherit-product, frameworks/native/build/tablet-7in-xhdpi-2048-dalvik-heap.mk)

$(call inherit-product, device/nintendo/nx/vendor/nx-vendor.mk)

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
    init.frig.rc \
    init.loki_foster_e_common.rc \
    init.nx.rc \
    init.recovery.nx.rc \
    init.sensors.nx.rc \
    init.vali.rc \
    power.nx.rc

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

# ATV specific stuff
ifeq ($(PRODUCT_IS_ATV),true)
    PRODUCT_PACKAGES += \
        android.hardware.tv.input@1.0-impl
endif

# Audio
ifeq ($(TARGET_TEGRA_AUDIO),nvaudio)
PRODUCT_PACKAGES += \
    audio_effects.xml \
    audio_policy_configuration.xml \
    nvaudio_conf.xml
endif

# CEC
PRODUCT_COPY_FILES := $(filter-out frameworks/native/data/etc/android.hardware.hdmi.cec.xml%android.hardware.hdmi.cec.xml,$(PRODUCT_COPY_FILES))

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.hdmi.cec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/staging/android.hardware.hdmi.cec.xml

PRODUCT_PACKAGES += \
    nx_cec.rc \
    cec_disable.xml \
    RC_for_stdp2550_cec

# Device Settings
PRODUCT_PACKAGES += \
    DeviceSettingsNX

# GMS
ifeq ($(WITH_GMS),true)
GMS_MAKEFILE=gms_minimal.mk
WITH_GMS_COMMS_SUITE := false
endif

# Joycons
PRODUCT_PACKAGES += \
    joycond \
    jc_setup

# Kernel Modules
PRODUCT_PACKAGES += \
    cypress-fmac-upstream

# Keylayouts
PRODUCT_PACKAGES += \
    gpio-keys.kl

# Light
PRODUCT_PACKAGES += \
    android.hardware.light@2.0-service-nvidia

# Loadable kernel modules
PRODUCT_PACKAGES += \
    init.lkm.rc \
    lkm_loader

# Media config
PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_ODM)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_ODM)/etc/media_codecs_google_video.xml
PRODUCT_PACKAGES += \
    media_codecs.xml
ifneq (,$(findstring nvmm,$(TARGET_TEGRA_OMX)))
PRODUCT_PACKAGES += \
    media_codecs_performance.xml \
    media_profiles_V1_0.xml \
    enctune.conf
endif

# Power
PRODUCT_PACKAGES += \
    powerhal.nx.xml

PRODUCT_COPY_FILES += \
    system/core/libprocessgroup/profiles/cgroups_28.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json \
    system/core/libprocessgroup/profiles/task_profiles_28.json:$(TARGET_COPY_OUT_VENDOR)/etc/task_profiles.json

# PHS
ifeq ($(TARGET_TEGRA_PHS),nvphs)
PRODUCT_PACKAGES += \
    nvphsd.conf
endif

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-service \
    android.hardware.sensors@1.0-impl \
    sensors.iio

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml

# Shipping API
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_l.mk)

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal@1.0-service-nvidia \
    thermalhal.nx.xml

# Trust HAL
PRODUCT_PACKAGES += \
    vendor.lineage.trust@1.0-service

# WiFi
PRODUCT_PACKAGES += \
    wifi_reset \
    WifiOverlay
