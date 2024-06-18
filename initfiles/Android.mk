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

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE           := fstab.nx
LOCAL_MODULE_CLASS     := ETC
LOCAL_SRC_FILES        := fstab.nx
LOCAL_VENDOR_MODULE    := true
LOCAL_REQUIRED_MODULES := fstab.nx_ramdisk
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := fstab.nx_ramdisk
LOCAL_MODULE_STEM   := fstab.nx
LOCAL_MODULE_CLASS  := ETC
LOCAL_SRC_FILES     := fstab.nx
LOCAL_MODULE_PATH   := $(TARGET_RAMDISK_OUT)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := init.nx.rc
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := init.nx.rc
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := init.vali.rc
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := init.vali.rc
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := init.frig.rc
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := init.frig.rc
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := init.recovery.nx.rc
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := init.recovery.nx.rc
LOCAL_MODULE_PATH  := $(TARGET_ROOT_OUT)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := power.nx.rc
LOCAL_MODULE_CLASS := ETC
LOCAL_ODM_MODULE   := true
LOCAL_SRC_FILES    := power.nx.rc
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := init.sensors.nx.rc
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := init.sensors.nx.rc
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := lkm_loader_target
LOCAL_SRC_FILES     := lkm_loader_target.sh
LOCAL_MODULE_SUFFIX := .sh
LOCAL_MODULE_CLASS  := EXECUTABLES
LOCAL_VENDOR_MODULE := true
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := init.loki_foster_e_common.rc
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := init.loki_foster_e_common.rc
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := init/hw
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE        := jc_setup
LOCAL_SRC_FILES     := jc_setup.sh
LOCAL_MODULE_SUFFIX := .sh
LOCAL_INIT_RC       := nx_jc.rc
LOCAL_MODULE_CLASS  := EXECUTABLES
LOCAL_VENDOR_MODULE := true
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := nx_cec.rc
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := nx_cec.rc
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := init
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE               := cec_disable.xml
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := cec_disable.xml
LOCAL_VENDOR_MODULE        := true
LOCAL_MODULE_RELATIVE_PATH := staging
include $(BUILD_PREBUILT)
