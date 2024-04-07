# AV
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.media.avsync=true

# Charger
PRODUCT_SYSTEM_PROPERTY_OVERRIDES += \
    persist.sys.NV_ECO.IF.CHARGING=false

# GMS
PRODUCT_SYSTEM_EXT_PROPERTY_OVERRIDES += \
    atv.setup.bt_remote_pairing=false

# HWC
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.tegra.stb.mode=0

# USB configfs
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.nv.usb.pid.adb=2000 \
    ro.vendor.nv.usb.pid.accessory.adb=2000 \
    ro.vendor.nv.usb.pid.audio_source.adb=2000 \
    ro.vendor.nv.usb.pid.ecm=2000 \
    ro.vendor.nv.usb.pid.ecm.adb=2000 \
    ro.vendor.nv.usb.pid.midi=2000 \
    ro.vendor.nv.usb.pid.midi.adb=2000 \
    ro.vendor.nv.usb.pid.mtp=2000 \
    ro.vendor.nv.usb.pid.mtp.adb=2000 \
    ro.vendor.nv.usb.pid.ncm=2000 \
    ro.vendor.nv.usb.pid.ncm.adb=2000 \
    ro.vendor.nv.usb.pid.ptp=2000 \
    ro.vendor.nv.usb.pid.ptp.adb=2000 \
    ro.vendor.nv.usb.pid.rndis=2000 \
    ro.vendor.nv.usb.pid.rndis.acm.adb=2000 \
    ro.vendor.nv.usb.pid.rndis.adb=2000 \
    ro.vendor.nv.usb.vid=057E \
    sys.usb.controller=700d0000.xudc \
    vendor.sys.usb.udc=700d0000.xudc
