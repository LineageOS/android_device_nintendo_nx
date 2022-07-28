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

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit full configuration for nx.
include device/nintendo/nx/lineage.mk

# Inherit some common AOSP stuff.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# Inherit some common ATV stuff.
$(call inherit-product, device/google/atv/products/atv_base.mk)

# Inherit device configuration for nx.
$(call inherit-product, device/nintendo/nx/device.mk)

PRODUCT_NAME := twrp_nx
PRODUCT_DEVICE := nx
PRODUCT_BRAND := NINTENDO
PRODUCT_MANUFACTURER := NINTENDO
PRODUCT_MODEL := Switch
