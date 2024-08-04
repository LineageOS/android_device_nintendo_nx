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

# The previous default crashes the current firmware
function fetch_nx_firmware() {
  echo -n "Downloading Wi-Fi firmware from SWR...";

  wget https://gitlab.com/switchroot/android/nx-firmware/-/raw/main/brcmfmac4356-pcie.clm_blob?ref_type=heads -O vendor/nintendo/nx/bcm_firmware/brcmfmac4356-pcie.clm_blob
  wget https://gitlab.com/switchroot/android/nx-firmware/-/raw/main/brcmfmac4356A3-pcie.txt?ref_type=heads -O vendor/nintendo/nx/bcm_firmware/brcmfmac4356A3-pcie.txt
  wget https://gitlab.com/switchroot/android/nx-firmware/-/raw/main/CYW4356A3_001.004.009.0092.0095.bin?ref_type=heads -O vendor/nintendo/nx/bcm_firmware/CYW4356A3_001.004.009.0092.0095.bin

  echo "";
}

fetch_nx_firmware;
