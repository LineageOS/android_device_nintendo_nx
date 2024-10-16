/*
 * Copyright (C) 2024 The LineageOS Project
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
import android.os.RemoteException;
import android.os.ServiceManager;
import android.os.SystemProperties;
import android.util.Log;
import android.view.IWindowManager;
import android.view.WindowManagerPolicyConstants;

import com.nvidia.NvCPLSvc.INvCPLRemoteService;

import com.nvidia.framework.NvConstants;

import vendor.nvidia.hardware.graphics.display.V1_0.INvDisplay;

public class DockService extends Service {
    private static final String TAG = DockService.class.getSimpleName();

    final private Receiver mReceiver = new Receiver();
    private INvDisplay mDisplayService;
    private IWindowManager mWindowManager;
    private INvCPLRemoteService mNvCPLSvc = null;

    @Override
    public IBinder onBind(Intent intent) {
        // We don't provide binding, so return null
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        mWindowManager = IWindowManager.Stub.asInterface(
                                ServiceManager.getService(Context.WINDOW_SERVICE));

        try {
            mDisplayService = INvDisplay.getService(true /* retry */);
        } catch (RemoteException e) {
            throw new RuntimeException(e);
        }

        mReceiver.init();

        return super.onStartCommand(intent, flags, startId);
    }

    final class Receiver extends BroadcastReceiver {
        private boolean mExternalDisplayConnected = false;

        private void updatePowerState(Context context, boolean connected) {
            final SharedPreferences sharedPrefs = context
                    .getSharedPreferences("org.lineageos.settings.device_preferences",
                            Context.MODE_PRIVATE);
            final boolean perfMode = sharedPrefs.getBoolean("perf_mode", false);
            final String sku = SystemProperties.get("ro.boot.hardware.sku", "");

            if (mNvCPLSvc == null) {
                try {
                    mNvCPLSvc = INvCPLRemoteService.Stub.asInterface(
                            ServiceManager.getService("nvcpl"));
                } catch (Exception e) {
                    Log.e(TAG, "Failed to bind to service. " + e.getMessage());
                    return;
                }
            }

            try {
                if (connected) {
                    DisplayUtils.setFanProfile(perfMode ? "Cool" : "Console");
                    DisplayUtils.setPowerMode(mNvCPLSvc, perfMode ?
                            NvConstants.NV_POWER_MODE_MAX_PERF :
                            NvConstants.NV_POWER_MODE_OPTIMIZED);
                } else {
                    DisplayUtils.setFanProfile(perfMode ? "Cool" : "Handheld");
                    DisplayUtils.setPowerMode(mNvCPLSvc, perfMode ?
                            NvConstants.NV_POWER_MODE_OPTIMIZED :
                            NvConstants.NV_POWER_MODE_BATTERY_SAVER);
                }
            } catch (RemoteException e) {
                Log.e(TAG, "Failed to set power profiles");
            }
        }

        public void init() {
            final IntentFilter filter = new IntentFilter();

            filter.addAction(WindowManagerPolicyConstants.ACTION_HDMI_PLUGGED);
            filter.addAction(Intent.ACTION_SCREEN_ON);
            filter.addAction(Intent.ACTION_USER_PRESENT);
            filter.addAction(DisplayUtils.POWER_UPDATE_INTENT);

            registerReceiver(this, filter);
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            SharedPreferences sharedPrefs = context.getSharedPreferences(
                    "org.lineageos.settings.device_preferences", Context.MODE_PRIVATE);
            final String action = intent.getAction();
            final boolean connected = intent.getBooleanExtra(
                    WindowManagerPolicyConstants.EXTRA_HDMI_PLUGGED_STATE, false);

            switch (action) {
                case WindowManagerPolicyConstants.ACTION_HDMI_PLUGGED:
                    if (mExternalDisplayConnected)
                        DisplayUtils.setDisplayMode(1, mDisplayService,
                            sharedPrefs);
                    else
                        DisplayUtils.setDisplayMode(0, mDisplayService,
                            sharedPrefs);

                    mExternalDisplayConnected = connected;

                    updatePowerState(context, mExternalDisplayConnected);

                case Intent.ACTION_SCREEN_ON:
                    Log.i(TAG, "Screen on");

                    DisplayUtils.setInternalDisplayState(!(mExternalDisplayConnected &&
                            sharedPrefs.getBoolean("disable_internal_on_external_connected",
                                    false)));

                    // Unlock device automatically if docked and reset res otherwise to
                    // work around broken HWC rotation
                    try {
                        if (mExternalDisplayConnected) {
                            mWindowManager.dismissKeyguard(null, null);
                        }
                    } catch (Exception ex) {
                        Log.w(TAG, "Failed to dismiss keyguard and reset resolution");
                    }

                    break;

                case DisplayUtils.POWER_UPDATE_INTENT:
                case Intent.ACTION_USER_PRESENT:
                    updatePowerState(context, mExternalDisplayConnected);
                    break;
                default:
                    break;
            }
        }
    }
}
