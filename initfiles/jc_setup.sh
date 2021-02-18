#!/system/xbin/bash

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
		if [ ${jc_type} = "1" ]; then
			echo "Name = Joy-Con (L)" >> ${bdroid_ini}
		else
			echo "Name = Joy-Con (R)" >> ${bdroid_ini}
		fi
	fi
done
