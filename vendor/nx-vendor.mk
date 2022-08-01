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

$(call inherit-product, device/nvidia/t210-common/vendor/t210.mk)
$(call inherit-product, device/nvidia/tegra-common/vendor/common-by-flags.mk)
$(call inherit-product, device/nintendo/nx/vendor/bcm_firmware/bcm.mk)
$(call inherit-product, device/nintendo/nx/vendor/nx-recovery.mk)

PRODUCT_PACKAGES += public.libraries

# Switch reboot2payload hekate
PRODUCT_PACKAGES += reboot_payload
