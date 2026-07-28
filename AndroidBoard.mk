# Copyright (C) 2020 The LineageOS Project
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

INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel
KERNEL_OUT ?= $(PRODUCT_OUT)/obj/KERNEL_OBJ

ifneq ($(TARGET_PREBUILT_KERNEL),)
DTB_PATH := $(dir $(TARGET_PREBUILT_KERNEL))
else ifneq ($(TARGET_KERNEL_PLATFORM_TARGET),)
DTB_PATH := $(abspath $(KERNEL_OUT))
else ifneq ($(filter 4.9, $(TARGET_KERNEL_VERSION)),)
DTB_PATH := $(abspath $(KERNEL_OUT)/arch/arm64/boot/dts)
else ifneq ($(findstring dtstree,$(TARGET_KERNEL_ADDITIONAL_FLAGS)),)
DTB_PATH := $(abspath $(KERNEL_OUT)/../lineage-oot/device-tree/platform/generic-dts/t21x/lineage)
else
DTB_PATH := $(abspath $(KERNEL_OUT)/arch/arm64/boot/dts/nvidia)
endif

INSTALLED_DTBIMAGE_TARGET := $(PRODUCT_OUT)/install/nx-plat.dtimg
$(INSTALLED_DTBIMAGE_TARGET): $(INSTALLED_KERNEL_TARGET) | mkdtimg
	echo -e ${CL_GRN}"Building nx DTImage"${CL_RST}
	@mkdir -p $(PRODUCT_OUT)/install
	$(HOST_OUT_EXECUTABLES)/mkdtimg create $@ --page_size=0x1000 \
		$(DTB_PATH)/tegra210-odin.dtb    --id=0x4F44494E --rev=0xa00 \
		$(DTB_PATH)/tegra210b01-odin.dtb --id=0x4F44494E --rev=0xb01 \
		$(DTB_PATH)/tegra210b01-vali.dtb --id=0x56414C49 --rev=0xa00 \
		$(DTB_PATH)/tegra210b01-fric.dtb --id=0x46524947 --rev=0xa00

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_DTBIMAGE_TARGET)

INSTALLED_RADIOIMAGE_TARGET += $(INSTALLED_DTBIMAGE_TARGET)

#CEC_XML_SYMLINK := $(TARGET_OUT_VENDOR)/etc/permissions/android.hardware.hdmi.cec.xml
#$(CEC_XML_SYMLINK): $(LOCAL_INSTALLED_MODULE)
#	$(hide) ln -sf /data/vendor/permissions/android.hardware.hdmi.cec.xml $@

ALL_DEFAULT_INSTALLED_MODULES += $(CEC_XML_SYMLINK)
