# Copyright (C) 2022-2024 The LineageOS Project
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

DTB_PART     = '/dev/block/by-name/dtb'
NX_FILES     = '/mnt/vendor/hos_data'

UBOOT_VERSION  = '2024.NX02.b201801'

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

def AddBootloaderFlash(info, input_zip):
  # check generated bl id
  info.script.AppendExtra("""
  ifelse(
    getprop("ro.bootloader") == "{0}",
    (
      ui_print("Correct bootloader already installed for " + getprop(ro.hardware));
    ),
    (
      ui_print("Flashing updated bootloader for " + getprop(ro.hardware));
      run_program("/system/bin/mkdir", "-p", "{1}");
      run_program("/system/bin/mount", "/dev/block/by-name/hos_data", "{1}");
""".format(UBOOT_VERSION, NX_FILES))

  # flash uploaded bl files
  info.script.AppendExtra("""
      run_program("/system/bin/sed", "-i", "s/LineageOS.*\]/LineageOS]/g", "{0}/bootloader/ini/android.ini");
      package_extract_file("firmware-update/bl31.bin", "{0}/switchroot/android/bl31.bin");
      package_extract_file("firmware-update/bl33.bin", "{0}/switchroot/android/bl33.bin");
      package_extract_file("firmware-update/boot.scr", "{0}/switchroot/android/boot.scr");
      run_program("/system/bin/umount", "{0}");
    )
  );
""".format(NX_FILES))

  # flash dtb
  info.script.AppendExtra("""
  package_extract_file("install/nx-plat.dtimg", "{0}");
""".format(DTB_PART))
