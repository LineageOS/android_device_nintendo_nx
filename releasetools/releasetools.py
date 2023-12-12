# Copyright (C) 2022 The LineageOS Project
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
#

""" Custom OTA commands for nx devices """

import common
import re
import os

APP_PART     = '/dev/block/by-name/APP'
DTB_PART     = '/dev/block/by-name/DTB'
VENDOR_PART  = '/dev/block/by-name/vendor'
NX_FILES     = '/mnt/vendor/hos_data'

NX_BL_VERSION = '2022.10-g4f111ee6dc'

def FullOTA_PostValidate(info):
  if 'INSTALL/bin/resize2fs_static' in info.input_zip.namelist():
    info.script.AppendExtra('run_program("/tmp/install/bin/resize2fs_static", "' + APP_PART + '");');
    info.script.AppendExtra('run_program("/tmp/install/bin/resize2fs_static", "' + VENDOR_PART + '");');

def FullOTA_Assertions(info):
  if 'RADIO/bl33.bin' in info.input_zip.namelist():
    CopyBlobs(info.input_zip, info.output_zip)
    AddBootloaderFlash(info, info.input_zip)
  else:
    AddBootloaderAssertion(info, info.input_zip)

def IncrementalOTA_Assertions(info):
  FullOTA_Assertions(info)

def CopyBlobs(input_zip, output_zip):
  for info in input_zip.infolist():
    f = info.filename
    if f.startswith("RADIO/") and (f.__len__() > len("RADIO/")):
      fn = f[6:]
      common.ZipWriteStr(output_zip, "firmware-update/" + fn, input_zip.read(f))

def AddBootloaderAssertion(info, input_zip):
  android_info = input_zip.read("OTA/android-info.txt").decode('utf-8')
  m = re.search(r"require\s+version-bootloader\s*=\s*(\S+)", android_info)
  if m:
    bootloaders = m.group(1).split("|")
    if "*" not in bootloaders:
      info.script.AssertSomeBootloader(*bootloaders)
    info.metadata["pre-bootloader"] = m.group(1)

def AddBootloaderFlash(info, input_zip):
  """ nx """
  info.script.AppendExtra('  ifelse(')
  info.script.AppendExtra('    getprop("ro.bootloader") == "' + NX_BL_VERSION + '",')
  info.script.AppendExtra('    (')
  info.script.AppendExtra('      ui_print("Correct bootloader already installed for " + getprop(ro.hardware));')
  info.script.AppendExtra('    ),')
  info.script.AppendExtra('    (')
  info.script.AppendExtra('      ui_print("Flashing updated bootloader for " + getprop(ro.hardware));')
  info.script.AppendExtra('      run_program("/system/bin/mkdir", "-p", "' + NX_FILES + '");')
  info.script.AppendExtra('      run_program("/system/bin/mount", "/dev/block/by-name/hos_data", "' + NX_FILES + '");')

  """ clean old bootloader """
  info.script.AppendExtra('      ifelse(')
  info.script.AppendExtra('        read_file("' + NX_FILES + '/switchroot/android/bl31.bin"),')
  info.script.AppendExtra('        (')
  info.script.AppendExtra('          ui_print("Your bootloader is already compatible with L4T-Loader");')
  info.script.AppendExtra('        ),')
  info.script.AppendExtra('        (')
  info.script.AppendExtra('          ui_print("Removing coreboot, as it is unused by L4T-Loader");')
  info.script.AppendExtra('          run_program("/system/bin/rm", "-f", "' + NX_FILES + '/switchroot/android/coreboot.rom");')
  info.script.AppendExtra('        )')
  info.script.AppendExtra('      );')

  """ flash uploaded bl files """
  info.script.AppendExtra('      package_extract_file("firmware-update/bl31.bin", "' + NX_FILES + '/switchroot/android/bl31.bin");')
  info.script.AppendExtra('      package_extract_file("firmware-update/bl33.bin", "' + NX_FILES + '/switchroot/android/bl33.bin");')
  info.script.AppendExtra('      package_extract_file("firmware-update/bootlogo_android.bmp", "' + NX_FILES + '/switchroot/android/bootlogo_android.bmp");')
  info.script.AppendExtra('      package_extract_file("firmware-update/icon_android_hue.bmp", "' + NX_FILES + '/switchroot/android/icon_android_hue.bmp");')
  info.script.AppendExtra('      run_program("/system/bin/umount", "' + NX_FILES + '");')
  info.script.AppendExtra('    )')
  info.script.AppendExtra('  );')


  """ flash dtb """
  info.script.AppendExtra('  package_extract_file("install/nx-plat.dtimg", "' + DTB_PART + '");')
