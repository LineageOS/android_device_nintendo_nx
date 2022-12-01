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

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE        := 00-android
LOCAL_MODULE_SUFFIX := .ini
LOCAL_SRC_FILES     := 00-android.ini
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)
include $(BUILD_PREBUILT)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/00-android.ini

include $(CLEAR_VARS)
LOCAL_MODULE        := bootlogo_android
LOCAL_MODULE_SUFFIX := .bmp
LOCAL_SRC_FILES     := bootlogo_android.bmp
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)
include $(BUILD_PREBUILT)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/bootlogo_android.bmp

include $(CLEAR_VARS)
LOCAL_MODULE        := icon_android_hue
LOCAL_MODULE_SUFFIX := .bmp
LOCAL_SRC_FILES     := icon_android_hue.bmp
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(PRODUCT_OUT)
include $(BUILD_PREBUILT)
INSTALLED_RADIOIMAGE_TARGET += $(PRODUCT_OUT)/icon_android_hue.bmp
