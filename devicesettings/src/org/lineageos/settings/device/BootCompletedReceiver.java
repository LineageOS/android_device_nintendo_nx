/*
 * Copyright (C) 2023 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.device;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.SystemProperties;

public class BootCompletedReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (SystemProperties.get("ro.product.device", "").equals("nx") &&
            !SystemProperties.get("ro.boot.hardware.sku", "").equals("vali")) {
            context.startService(new Intent(context, DockService.class));
        }

        // Set preferred OLED panel mode
        if(SystemProperties.get("ro.boot.hardware.sku", "").equals("frig")) {
            final SharedPreferences sharedPrefs = context.getSharedPreferences(
                "org.lineageos.settings.device_preferences", Context.MODE_PRIVATE);
            final String panelMode = sharedPrefs.getString("panel_color_mode", "0x23");

            DisplayUtils.setPanelColorMode(panelMode);
        }
    }
}
