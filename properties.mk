# AV
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.media.avsync=true

# Charger
PRODUCT_SYSTEM_PROPERTY_OVERRIDES += \
    persist.sys.NV_ECO.IF.CHARGING=false

# Display Mirroring Dialog
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.sysui.disable_mirroring_confirmation_dialog=true

# GMS
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    atv.setup.bt_remote_pairing=false

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
