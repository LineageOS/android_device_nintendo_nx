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

//	  id        dpi
static const std::map<unsigned long, std::string> panel_map = {
	{ 0xf20,    "186" }, // INN 6.2
	{ 0xf30,    "186" }, // AUO 6.2
	{ 0x10,     "186" }, // JDI 6.2
	{ 0x1020,   "192" }, // INN 5.5
	{ 0x1030,   "192" }, // AUO 5.5
	{ 0x1040,   "192" }, // SHP 5.5
	{ 0x10e1,   "288" }, // RR Super5 OLED FHD
	{ 0x2050,   "186" }, // SAM 7.0
	{ 0xf83,    "186" }, // Clone 6.2
	{ 0xb3,     "192" }, // Clone 5.5
	{ 0x0,      "192" }, // Clone 5.5
};

void vendor_load_properties()
{

	//	  device    name      hardware   model            id      sku api dpi
	std::vector<tegra_init::devices> devices = {
		{ "nx",     "odin",   "nx",      "Switch",        0x494E, 0,  27, 0 },
		{ "nx",     "modin",  "nx",      "Switch v2",     0x494E, 1,  27, 0 },
		{ "nx",     "vali",   "nx",      "Switch Lite",   0x4C49, 2,  27, 0 },
		{ "nx",     "fric",   "nx",      "Switch OLED",   0x4947, 3,  27, 0 }
 	};

	tegra_init ti(devices);

	tegra_init::build_version tav = { "11", "RQ1A.210105.003", "7825230_4387.0822" };
	ti.set_fingerprints(tav);

	ti.set_properties();

	unsigned long panel_id = std::stoul(ti.property_get("ro.boot.panel_id"), NULL, 16);

	if (auto search = example.find(panel_id); search != example.end())
		ti.property_set("ro.sf.lcd_density", search->second);
	else
		ti.property_set("ro.sf.lcd_density", "186");

	if (ti.recovery_context()) {
		ti.property_set("ro.product.vendor.model", ti.property_get("ro.product.model"));
		ti.property_set("ro.product.vendor.manufacturer", ti.property_get("ro.product.manufacturer"));
	}
}
