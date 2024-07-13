#!/vendor/bin/sh

/vendor/bin/insmod /vendor/lib/modules/pci-tegra.ko

/vendor/bin/insmod /vendor/lib/modules/compat.ko
/vendor/bin/insmod /vendor/lib/modules/cy_cfg80211.ko
/vendor/bin/insmod /vendor/lib/modules/brcmutil.ko
/vendor/bin/insmod /vendor/lib/modules/brcmfmac.ko
