LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(call all-java-files-under, src)
LOCAL_CERTIFICATE := platform
LOCAL_PRIVATE_PLATFORM_APIS := true
LOCAL_PRIVILEGED_MODULE := true
LOCAL_PACKAGE_NAME := DeviceSettingsNX
LOCAL_OVERRIDES_PACKAGES := DeviceSettings
LOCAL_MODULE_TAGS := optional

LOCAL_USE_AAPT2 := true

LOCAL_STATIC_ANDROID_LIBRARIES := \
    androidx.core_core \
    androidx.preference_preference

LOCAL_STATIC_JAVA_LIBRARIES := \
    org.lineageos.platform.internal \
    vendor.nvidia.hardware.graphics.display-V1.0-java

LOCAL_RESOURCE_DIR := \
    $(LOCAL_PATH)/res \
    $(TOP)/packages/resources/devicesettings/res

LOCAL_PROGUARD_FLAG_FILES := proguard.flags

LOCAL_REQUIRED_MODULES := \
    privapp-permissions-lineage-displaysettings-nx.xml

include $(BUILD_PACKAGE)

include $(CLEAR_VARS)
LOCAL_MODULE               := privapp-permissions-lineage-displaysettings-nx.xml
LOCAL_MODULE_CLASS         := ETC
LOCAL_SRC_FILES            := permissions/privapp-permissions-lineage-displaysettings.xml
LOCAL_MODULE_RELATIVE_PATH := permissions
include $(BUILD_PREBUILT)
