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


# Inherit some common AOSP stuff
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, packages/services/Car/car_product/build/car.mk)


# Inherit NX-specific LineageOS additions.
include device/nintendo/nx/lineage.mk

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, device/lineage/car/lineage_car_vendor.mk)
$(call inherit-product, vendor/lineage/config/common_car.mk)

# Inherit device configuration for nx.
$(call inherit-product, device/nintendo/nx/device.mk)

PRODUCT_NAME := lineage_nx_car
PRODUCT_DEVICE := nx
PRODUCT_BRAND := Nintendo
PRODUCT_MANUFACTURER := Nintendo
PRODUCT_MODEL := Switch
