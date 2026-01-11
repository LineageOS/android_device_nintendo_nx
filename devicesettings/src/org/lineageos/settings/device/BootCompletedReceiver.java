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
import android.hardware.power.IPower;
import android.hardware.power.Mode;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.os.SystemProperties;
import android.util.Log;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationChannelCompat;
import androidx.core.app.NotificationManagerCompat;

public class BootCompletedReceiver extends BroadcastReceiver {
    private static final String TAG = BootCompletedReceiver.class.getSimpleName();
    private static final String SEEN_RSMOUSE_PROP = "persist.devicesettingsnx.hasseenrsmouse";
    private static final String CHANNEL_ID = "switchconfig";
    private IPower mPerfMgr;

    @Override
    public void onReceive(Context context, Intent intent) {
        if (SystemProperties.get("ro.product.device", "").equals("nx") &&
            !SystemProperties.get("ro.boot.hardware.sku", "").equals("vali")) {
            context.startService(new Intent(context, DockService.class));
        }

        final SharedPreferences sharedPrefs = context.getSharedPreferences(
            "org.lineageos.settings.device_preferences", Context.MODE_PRIVATE);

        mPerfMgr = IPower.Stub.asInterface(
            ServiceManager.waitForDeclaredService(IPower.DESCRIPTOR + "/default"));

        // Enable/disable perf mode power mode with perfmgr
        final boolean perfMode = sharedPrefs.getBoolean("perf_mode", false);

        try {
            mPerfMgr.setMode(Mode.SUSTAINED_PERFORMANCE, false);
            if (!perfMode)
                mPerfMgr.setMode(Mode.LOW_POWER, true);
            else
            mPerfMgr.setMode(Mode.LOW_POWER, false);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to set on boot power mode!");
        }

        // Set preferred OLED panel mode
        if(SystemProperties.get("ro.boot.hardware.sku", "").equals("fric")) {
            final String panelMode = sharedPrefs.getString("panel_color_mode", "0x23");

            DisplayUtils.setPanelColorMode(panelMode);
        }

        if (!SystemProperties.getBoolean(SEEN_RSMOUSE_PROP, false)) {
            NotificationChannelCompat channel = new NotificationChannelCompat.Builder(
                    CHANNEL_ID,
                    NotificationManagerCompat.IMPORTANCE_MAX
            )
                    .setName(context.getString(R.string.display_panel_title))
                    .setDescription(context.getString(R.string.notif_provider_desc))
                    .setShowBadge(true)
                    .build();

            NotificationManagerCompat notificationManager =
                    NotificationManagerCompat.from(context);
            notificationManager.createNotificationChannel(channel);

            NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
                    .setSmallIcon(R.drawable.ic_settings_additional_buttons)
                    .setContentTitle(context.getString(R.string.rsmouse_notif_title))
                    .setContentText(context.getString(R.string.rsmouse_notif_content))
                    .setCategory(NotificationCompat.CATEGORY_SYSTEM)
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .extend(new NotificationCompat.TvExtender().setChannelId(CHANNEL_ID));
            SystemProperties.set(SEEN_RSMOUSE_PROP, "true");

            notificationManager.notify(1, builder.build());
        }
    }
}
