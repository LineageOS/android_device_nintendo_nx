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

void vendor_load_properties()
{
       //                                             device    name     model          id     sku api dpi
       std::vector<tegra_init::devices> devices = { { "nx",     "odin",  "Switch",      0x494E, 1, 27, 214 },
                                                    { "nx",     "modin", "Switch v2",   0x494F, 1, 27, 214 },
                                                    { "nx",     "vali",  "Switch Lite", 0x4C49, 2, 27, 214 },
                                                    { "nx",     "frig",  "Switch OLED", 0x4947, 3, 27, 214 } };
        // NOTE: modin has same board id as odin, but we bumped by 0x00000001 to keep id's unique for dtimg entry indexing

	tegra_init ti(devices);

    tegra_init::build_version tav = { "11", "RQ1A.210105.003", "7825230_3167.5736" };
    ti.set_fingerprints(tav);

	ti.set_properties();

	if (ti.recovery_context()) {
		ti.property_set("ro.product.vendor.model", ti.property_get("ro.product.model"));
		ti.property_set("ro.product.vendor.manufacturer", ti.property_get("ro.product.manufacturer"));
	}
}
