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
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.SystemProperties;
import android.util.Log;
import android.view.WindowManagerPolicyConstants;
import androidx.fragment.app.FragmentActivity;

public class DisplaySettingsLeanbackActivity extends FragmentActivity {
    private final static String TAG = DisplaySettingsLeanbackActivity.class.getSimpleName();
    public final Receiver mReceiver = new Receiver();
    public boolean mExternalDisplayConnected;
    private String sku = SystemProperties.get("ro.product.name", "");

    protected void onCreate(Bundle savedInstanceState) {
        Log.i(TAG, "Starting " + DisplaySettingsFragmentLeanback.class.getSimpleName());
        super.onCreate(savedInstanceState);
        setContentView(R.xml.settings_fragment);
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (!sku.equals("vali"))
            unregisterReceiver(mReceiver);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (!sku.equals("vali"))
            mReceiver.init(this);
    }

    final class Receiver extends BroadcastReceiver {
        public boolean mBlocked;
        private boolean mReceivedInitialIntent = false;

        public void init(Context context) {
            mReceivedInitialIntent = false;

            // Refresh UI on external display status change
            IntentFilter filter = new IntentFilter();
            filter.addAction(WindowManagerPolicyConstants.ACTION_HDMI_PLUGGED);
            context.registerReceiver(this, filter);
        }

        public void onReceive(Context context, Intent intent) {
            mExternalDisplayConnected = intent.getBooleanExtra(
                    WindowManagerPolicyConstants.EXTRA_HDMI_PLUGGED_STATE, false);

            if (mBlocked)
                return;

            if (mReceivedInitialIntent)
                recreate();

            mReceivedInitialIntent = true;
        }
    }
}
