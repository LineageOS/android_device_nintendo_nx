# AV
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.media.avsync=true

# Baylibre audio
ifeq ($(TARGET_AUDIO_HAL),baylibre)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.audio.primary.device=3
endif

# Charger
PRODUCT_SYSTEM_PROPERTY_OVERRIDES += \
    persist.sys.NV_ECO.IF.CHARGING=false

# Display Mirroring Dialog
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.sysui.disable_mirroring_confirmation_dialog=true

# GMS
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    atv.setup.bt_remote_pairing=false

# Graphics
ifneq ($(filter 4.9 5.10, $(TARGET_KERNEL_VERSION)),)
PRODUCT_PROPERTY_OVERRIDES += \
    debug.sf.latch_unsignaled=1 \
    ro.surface_flinger.force_hwc_copy_for_virtual_displays=true \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3 \
    ro.surface_flinger.max_virtual_display_dimension=4096
endif

# HWC
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.tegra.stb.mode=0

# USB configfs
PRODUCT_PROPERTY_OVERRIDES += \
	ro.vendor.nv.usb.pid.adb=2000 \
	ro.vendor.nv.usb.pid.rndis.acm.adb=200A \
	ro.vendor.nv.usb.pid.accessory.adb=200B \
	ro.vendor.nv.usb.pid.audio_source.adb=200C \
	ro.vendor.nv.usb.pid.ecm=200D \
	ro.vendor.nv.usb.pid.ecm.adb=200E \
	ro.vendor.nv.usb.pid.midi=201A \
	ro.vendor.nv.usb.pid.midi.adb=201B \
	ro.vendor.nv.usb.pid.mtp=201C \
	ro.vendor.nv.usb.pid.mtp.adb=201D \
	ro.vendor.nv.usb.pid.ncm=201E \
	ro.vendor.nv.usb.pid.ncm.adb=201F \
	ro.vendor.nv.usb.pid.ptp=202A \
	ro.vendor.nv.usb.pid.ptp.adb=202B \
	ro.vendor.nv.usb.pid.rndis=202C \
	ro.vendor.nv.usb.pid.rndis.adb=202D \
	ro.vendor.nv.usb.vid=057E \
	sys.usb.controller=700d0000.xudc \
	vendor.sys.usb.udc=700d0000.xudc
