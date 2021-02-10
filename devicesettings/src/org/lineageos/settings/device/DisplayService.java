/*
 * Copyright (C) 2020 The LineageOS Project
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

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.util.Log;
import android.view.WindowManagerPolicyConstants;

public class DisplayService extends Service {
    private static final String TAG = DisplayService.class.getSimpleName();
    final Receiver mReceiver = new Receiver();

    @Override
    public IBinder onBind(Intent intent) {
        // We don't provide binding, so return null
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        mReceiver.init();

        return super.onStartCommand(intent, flags, startId);
    }

    final class Receiver extends BroadcastReceiver {
        private boolean mExternalDisplayConnected = false;

        public void init() {
            IntentFilter filter = new IntentFilter();

            filter.addAction(WindowManagerPolicyConstants.ACTION_HDMI_PLUGGED);
            filter.addAction(Intent.ACTION_SCREEN_ON);

            registerReceiver(this, filter);
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            SharedPreferences sharedPrefs = context.getSharedPreferences("org.lineageos.settings.device_preferences", context.MODE_PRIVATE);
            Log.w(TAG, intent.getAction());
            String action = intent.getAction();

            switch (action) {
                case WindowManagerPolicyConstants.ACTION_HDMI_PLUGGED:
                    mExternalDisplayConnected = intent.getBooleanExtra(WindowManagerPolicyConstants.EXTRA_HDMI_PLUGGED_STATE, false);
                case Intent.ACTION_SCREEN_ON:
                    DisplayUtils.setInternalDisplayState(!(mExternalDisplayConnected && sharedPrefs.getBoolean("disable_internal_on_external_connected", false)));
                default:
                    break;
            }
        }
    }

    ;
}
