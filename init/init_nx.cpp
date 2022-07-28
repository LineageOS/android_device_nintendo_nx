/*
   Copyright (c) 2013, The Linux Foundation. All rights reserved.
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of The Linux Foundation nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
   THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
   ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "init_tegra.h"

#include <map>

void vendor_set_usb_product_ids(tegra_init *ti)
{
	std::map<std::string, std::string> mCommonUsbIds, mDeviceUsbIds;

	mCommonUsbIds["ro.vendor.nv.usb.pid.rndis.acm.adb"]    	= "AF00";
	mCommonUsbIds["ro.vendor.nv.usb.pid.adb"]              	= "7104";
	mCommonUsbIds["ro.vendor.nv.usb.pid.accessory.adb"]    	= "7105";
	mCommonUsbIds["ro.vendor.nv.usb.pid.audio_source.adb"] 	= "7106";
	mCommonUsbIds["ro.vendor.nv.usb.pid.ncm"]              	= "7107";
	mCommonUsbIds["ro.vendor.nv.usb.pid.ncm.adb"]          	= "7108";
	mCommonUsbIds["ro.vendor.nv.usb.pid.midi"]             	= "7109";
	mCommonUsbIds["ro.vendor.nv.usb.pid.midi.adb"]         	= "710A";
	mCommonUsbIds["ro.vendor.nv.usb.pid.ecm"]              	= "710B";
	mCommonUsbIds["ro.vendor.nv.usb.pid.ecm.adb"]          	= "710C";

	mDeviceUsbIds["ro.vendor.nv.usb.vid"]           	= "057E";
	mDeviceUsbIds["ro.vendor.nv.usb.pid.mtp"]       	= "2000";
	mDeviceUsbIds["ro.vendor.nv.usb.pid.mtp.adb"]   	= "2000";
	mDeviceUsbIds["ro.vendor.nv.usb.pid.ptp"]       	= "2000";
	mDeviceUsbIds["ro.vendor.nv.usb.pid.ptp.adb"]   	= "2000";
	mDeviceUsbIds["ro.vendor.nv.usb.pid.rndis"]     	= "2000";
	mDeviceUsbIds["ro.vendor.nv.usb.pid.rndis.adb"] 	= "2000";

	for (auto const& id : mDeviceUsbIds)
		ti->property_set(id.first, id.second);

	for (auto const& id : mCommonUsbIds)
		ti->property_set(id.first, id.second);
}

void vendor_set_nrdp_props(tegra_init *ti)
{
	ti->property_set("ro.vendor.nrdp.audio.otfs", "true");
	ti->property_set("ro.vendor.nrdp.validation", "ninja_6");
}

void vendor_load_properties()
{
       //                                             device    name     model          id   sku api dpi
       std::vector<tegra_init::devices> devices = { { "nx",     "odin",  "Switch",      7888, 1, 27, 240 },
                                                    { "nx",     "modin", "Switch v2",   7888, 1, 27, 240 },
                                                    { "nx",     "vail",  "Switch Lite", 7888, 2, 27, 240 },
                                                    { "nx",     "frig",  "Switch OLED", 7888, 3, 27, 240 } };

	tegra_init ti(devices);

	ti.set_properties();

	if (ti.recovery_context()) {
		ti.property_set("ro.product.vendor.model", ti.property_get("ro.product.model"));
		ti.property_set("ro.product.vendor.manufacturer", ti.property_get("ro.product.manufacturer"));

		// Unset avb flags. This is to ignore compatibility checks on unified builds
		if (ti.is_model("mdarcy") || ti.is_model("sif"))
			ti.property_set("ro.boot.avb_version", "");
	}

	if (ti.vendor_context() || ti.recovery_context()) {
		vendor_set_usb_product_ids(&ti);

		if (ti.property_get("ro.build.characteristics") == "tv") {
			vendor_set_nrdp_props(&ti);
		}
	}
}
