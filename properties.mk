# AV
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.media.avsync=true

# Bpf
PRODUCT_PROPERTY_OVERRIDES += \
    ro.kernel.ebpf.supported=1

# Charger
PRODUCT_SYSTEM_PROPERTY_OVERRIDES += \
    persist.sys.NV_ECO.IF.CHARGING=false

# USB configfs
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.nv.usb.pid.adb=7104 \
    ro.vendor.nv.usb.pid.accessory.adb=7105 \
    ro.vendor.nv.usb.pid.audio_source.adb=7106 \
    ro.vendor.nv.usb.pid.ecm=710B \
    ro.vendor.nv.usb.pid.ecm.adb=710C \
    ro.vendor.nv.usb.pid.midi=7109 \
    ro.vendor.nv.usb.pid.midi.adb=710A \
    ro.vendor.nv.usb.pid.mtp=2000 \
    ro.vendor.nv.usb.pid.mtp.adb=2000 \
    ro.vendor.nv.usb.pid.ncm=7107 \
    ro.vendor.nv.usb.pid.ncm.adb=7108 \
    ro.vendor.nv.usb.pid.ptp=2000 \
    ro.vendor.nv.usb.pid.ptp.adb=2000 \
    ro.vendor.nv.usb.pid.rndis=2000 \
    ro.vendor.nv.usb.pid.rndis.acm.adb=AF00 \
    ro.vendor.nv.usb.pid.rndis.adb=2000 \
    ro.vendor.nv.usb.vid=057E \
    sys.usb.controller=700d0000.xudc \
    vendor.sys.usb.udc=700d0000.xudc
