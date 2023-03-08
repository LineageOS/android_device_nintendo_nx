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

ifeq ($(TARGET_PREBUILT_KERNEL),)
INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel
INSTALLED_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/recovery.img

ifeq ($(filter 3.10 4.9, $(TARGET_TEGRA_KERNEL)),)
DTB_SUBFOLDER := nvidia/
endif

INSTALLED_DTBIMAGE_TARGET := $(PRODUCT_OUT)/install/nx-plat.dtimg

$(INSTALLED_DTBIMAGE_TARGET): $(INSTALLED_KERNEL_TARGET) | mkdtimg
	echo -e ${CL_GRN}"Building nx platform DTImage"${CL_RST}
	@mkdir -p $(PRODUCT_OUT)/install
	$(HOST_OUT_EXECUTABLES)/mkdtimg create $@ --page_size=0x1000 \
		$(KERNEL_OUT)/arch/arm64/boot/dts/$(DTB_SUBFOLDER)/tegra210-odin.dtb --id=0x4F44494E \
		$(KERNEL_OUT)/arch/arm64/boot/dts/$(DTB_SUBFOLDER)/tegra210b01-odin.dtb --id=0x4F44494F --rev=0xb01 \
		$(KERNEL_OUT)/arch/arm64/boot/dts/$(DTB_SUBFOLDER)/tegra210b01-vali.dtb --id=0x56414C49 \
		$(KERNEL_OUT)/arch/arm64/boot/dts/$(DTB_SUBFOLDER)/tegra210b01-frig.dtb --id=0x46524947

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_DTBIMAGE_TARGET)
endif

POWER_RC_SYMLINK := $(TARGET_OUT_VENDOR)/odm/etc/power.nx.rc
$(POWER_RC_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	$(hide) ln -sf /data/vendor/nvcpl/power.nx.rc $@

ALL_DEFAULT_INSTALLED_MODULES += $(POWER_RC_SYMLINK)

CEC_XML_SYMLINK := $(TARGET_OUT_VENDOR)/etc/permissions/android.hardware.hdmi.cec.xml
$(CEC_XML_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	$(hide) ln -sf /data/vendor/permissions/android.hardware.hdmi.cec.xml $@

ALL_DEFAULT_INSTALLED_MODULES += $(CEC_XML_SYMLINK)
