#!/system_ext/bin/bash
set -e

# https://stackoverflow.com/a/28409737
# section key value path -> string
function set_ini_val {
    sed -i '/^\['${1}']/,/^\[/{s/^'${2}'[[:space:]]*=.*/'${2}' = '${3}'/}'  ${4}
}

# https://stackoverflow.com/a/40778047
# section key path -> string
function get_ini_val {
    sed -nr '/^\['${1}']/ { :l /^'${2}'[ ]*=/ { s/.*=[ ]*//; s/\r//g; p; q;}; n; b l;}' ${3}
}

# section path -> int
function ini_has_section {
    grep -F "[${1}]" ${2} &> /dev/null
    return $?
}

# https://stackoverflow.com/a/19032792
# string -> string
function string_to_lower {
    echo $1 | sed 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'
}

# https://stackoverflow.com/a/34327002
# string -> string
function string_to_le {
    i=${#1}

    while [ $i -gt 0 ]
    do
            i=$[$i-2]
            echo -n ${1:$i:2}
    done
}

jc_ini="${1}"
bdroid_ini="${2}"
jc_sections=("joycon_00" "joycon_01")

for jc_section in ${jc_sections[@]}; do
    jc_type=$(get_ini_val ${jc_section} type ${jc_ini})
    if [ ${jc_type} = "0" ]; then
        echo ${jc_section} not found!
        continue
    fi

    jc_mac=$(string_to_lower $(get_ini_val ${jc_section} mac ${jc_ini}))
    jc_ltk=$(string_to_le $(string_to_lower $(get_ini_val ${jc_section} ltk ${jc_ini})))

    if ini_has_section ${jc_mac} ${bdroid_ini}; then
        echo "Joycon entry present in bluedroid ini, update LTK"
        set_ini_val ${jc_mac} LinkKey ${jc_ltk} ${bdroid_ini}
    else
        echo "Joycon entry not present in bluedroid ini, create it"
        echo "" >> ${bdroid_ini}
        echo "[${jc_mac}]" >> ${bdroid_ini}
        echo "LinkKey = ${jc_ltk}" >> ${bdroid_ini}
        echo "LinkKeyType = 4" >> ${bdroid_ini}
        echo "Service = 00001124-0000-1000-8000-00805f9b34fb 00000000-0000-1000-8000-00805f9b34fb 00000000-0000-1000-8000-00805f9b34fb" >> ${bdroid_ini}
        echo "DevClass = 1288" >> ${bdroid_ini}
        echo "DevType = 1" >> ${bdroid_ini}
        echo "AddrType = 0" >> ${bdroid_ini}
        echo "SecureConnectionsSupported = 0" >> ${bdroid_ini}
        echo "LinkKeyType = 4" >> ${bdroid_ini}
        echo "PinLength = 0" >> ${bdroid_ini}
        echo "MaxSessionKeySize = 16" >> ${bdroid_ini}
        echo "SdpDiManufacturer = 1406" >> ${bdroid_ini}
        echo "SdpDiHardwareVersion = 1" >> ${bdroid_ini}
        echo "SdpDiVendorIdSource = 2" >> ${bdroid_ini}
        echo "HidDbVersion = 1" >> ${bdroid_ini}
        echo "HidAttrMask = 32885" >> ${bdroid_ini}
        echo "HidSubClass = 8" >> ${bdroid_ini}
        echo "HidAppId = 6" >> ${bdroid_ini}
        echo "HidVendorId = 1406" >> ${bdroid_ini}
        echo "HidVersion = 1" >> ${bdroid_ini}
        echo "HidCountryCode = 33" >> ${bdroid_ini}
        echo "HidSSRMaxLatency = 65535" >> ${bdroid_ini}
        echo "HidSSRMinTimeout = 65535" >> ${bdroid_ini}
        echo "HidDescriptor = 05010905a1010601ff8521092175089530810285300930750895308102853109317508966901810285320932750896690181028533093375089669018102853f05091901291015002501750195108102050109391500250775049501814205097504950181010501093009310933093416000027ffff00007510950481020601ff85010901750895309102851009107508953091028511091175089530910285120912750895309102c0" >> ${bdroid_ini}
        echo "HidReConnectAllowed = 1" >> ${bdroid_ini}
        if [ ${jc_type} = "1" ]; then
                echo "Name = Joy-Con (L)"  >> ${bdroid_ini}
                echo "SdpDiModel = 8198"   >> ${bdroid_ini}
                echo "HidProductId = 8198" >> ${bdroid_ini}
        else
                echo "Name = Joy-Con (R)"  >> ${bdroid_ini}
                echo "SdpDiModel = 8199"   >> ${bdroid_ini}
                echo "HidProductId = 8199" >> ${bdroid_ini}
        fi
    fi
done
