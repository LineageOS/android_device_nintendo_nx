# Copyright (C) 2019 The LineageOS Project
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

""" Custom OTA commands for NX devices """

import common
import re
import os

APP_PART     = '/dev/block/by-name/APP'
DTB_PART     = '/dev/block/by-name/DTB'
STAGING_PART = '/dev/block/by-name/USP'
VBMETA_PART  = '/dev/block/by-name/vbmeta'
VENDOR_PART  = '/dev/block/by-name/vendor'
NX_SD     = '/external_sd/switchroot/android/'

DTSFILENAME_PATH    = '/proc/device-tree/nvidia,dtsfilename'

NX_BL_VERSION    = '2020.04-03755-gf4d532d00d-rev3'

def FullOTA_PostValidate(info):
  if 'INSTALL/bin/resize2fs_static' in info.input_zip.namelist():
    info.script.AppendExtra('run_program("/tmp/install/bin/resize2fs_static", "' + APP_PART + '");');
    info.script.AppendExtra('run_program("/tmp/install/bin/resize2fs_static", "' + VENDOR_PART + '");');

def FullOTA_Assertions(info):
  if 'RADIO/coreboot.rom' in info.input_zip.namelist():
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
  """ NX Detected """
  info.script.AppendExtra('ifelse(')
  info.script.AppendExtra('  getprop("ro.hardware") == "nx",')
  info.script.AppendExtra('  (')
  info.script.AppendExtra('    ifelse(')
  info.script.AppendExtra('      getprop("ro.bootloader") == "' + NX_BL_VERSION + '",')
  info.script.AppendExtra('      (')
  info.script.AppendExtra('        ui_print("Correct bootloader already installed for fused " + getprop(ro.hardware));')
  info.script.AppendExtra('      ),')
  info.script.AppendExtra('      (')
  info.script.AppendExtra('      ui_print("Flashing updated bootloader for fused " + getprop(ro.hardware));')
  info.script.AppendExtra('      package_extract_file("firmware-update/coreboot.rom", "' + NX_FILES + 'coreboot.rom");')
  info.script.AppendExtra('      package_extract_file("firmware-update/boot.scr", "' + NX_FILES + 'boot.scr");')
  info.script.AppendExtra('      package_extract_file("firmware-update/bootlogo_android.bmp", "' + NX_FILES + 'bootlogo_android.bmp");')
  info.script.AppendExtra('      package_extract_file("firmware-update/icon_android_hue.bmp", "' + NX_FILES + 'icon_android_hue.bmp");')
  info.script.AppendExtra('      package_extract_file("firmware-update/00-android.ini", "' + NX_BL_CONFIG + '00-android.ini");')
  info.script.AppendExtra('      ),')
  info.script.AppendExtra('    );')
  info.script.AppendExtra('    package_extract_file("install/" + tegra_get_dtbname(), "' + DTB_PART + '");')
  info.script.AppendExtra('  )')
  info.script.AppendExtra(');')

  info.script.AppendExtra('  ),')

  info.script.AppendExtra('  )')
  info.script.AppendExtra(');')
