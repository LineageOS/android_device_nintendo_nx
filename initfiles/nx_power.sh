#!/vendor/bin/sh
#
# Copyright (C) 2023 The LineageOS Project
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

script=$0

model=$(getprop ro.hardware)        # Model
sku=$(getprop ro.boot.hardware.sku) # SKU
boost=$(getprop ro.boot.boost)            # Overclock

/vendor/bin/log -t "$script" -p i "**** GENERATING POWER RC FOR ARCH:" $model "SKU:" $sku "****"
/vendor/bin/log -t "$script" -p i "**** BOOST:" $boost "****"

outfile=/data/vendor/nvcpl/power.nx.rc
rm -f $outfile
touch $outfile

# Set default clocks (based on HOS T210 limits)
max_cpu="1785000 1785000 1428000"
max_gpu="921600 768000 460800"
min_gpu="0 0 0"
min_cpu="0 0 0"

if [ "$sku" = "odin" ]; then
    min_gpu="153600 153600 153600"
elif [ "$sku" = "vali" ]; then
    max_gpu="768000 768000 460800"

    # Set Vali CPU clocks
    if [ $boost = 1 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 1, WITHIN SAFE LIMITS)"
        max_cpu="1963500 1963500 1785000"
    fi
elif [ "$sku" = "modin" ] || [ "$sku" = "frig" ]; then
    # Disable GPU clock userspace limiting (let kernel handle it)
    if [ $boost = 1 ]; then
        max_gpu="0 0 0"
    fi

    # Set T210B01 CPU clocks
    if [ $boost = 1 ]; then
        /vendor/bin/log -t "$script" -p i "WARNING: APPLYING OVERCLOCK (TIER 1, WITHIN SAFE LIMITS)"
        max_cpu="1963500 1963500 1785000"
    fi
fi

/vendor/bin/log -t "$script" -p i "RESULT: CPU:" $max_cpu "GPU:" $max_gpu

echo "# This file is auto-generated. Do not modify."                    >> $outfile
echo "# Key   Docked Perf   Docked Opt / Undocked Perf   Undocked Opt"  >> $outfile
echo "NV_DEFAULT_MODE 0"                                                >> $outfile
echo "panelresolution=-1X-1"                                            >> $outfile
echo "NV_MAX_FREQ $max_cpu"                                             >> $outfile
echo "NV_MIN_FREQ $min_cpu"                                             >> $outfile
echo "NV_MAX_GPU_FREQ $max_gpu"                                         >> $outfile
echo "NV_MIN_GPU_FREQ 0 0 0"                                            >> $outfile
echo "NV_APM_CPU_BOOST 5 5 0"                                           >> $outfile
echo "NV_APM_GPU_BOOST 5 5 0"                                           >> $outfile
echo "NV_APM_FRT_BOOST 5 5 0"                                           >> $outfile
echo "NV_APM_FRT_MIN 20 20 15"                                          >> $outfile
echo "NV_APM_LOADAPPFRT 0 0 0"                                          >> $outfile
