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
import android.content.pm.PackageManager;
import android.graphics.Point;
import android.hardware.display.DisplayManager;
import android.os.IBinder;
import android.os.Parcel;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.os.UserHandle;
import android.util.Log;
import android.view.IWindowManager;
import android.view.WindowManagerPolicyConstants;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import com.nvidia.NvAppProfiles;
import com.nvidia.NvConstants;

public class DockService extends Service {
    private static final String TAG = DockService.class.getSimpleName();
    private static final String NVCPL_SERVICE_KEY = "nvcpl";
    private static final int SURFACE_FLINGER_READ_CODE = 1010;
    private static final int SURFACE_FLINGER_DISABLE_OVERLAYS_CODE = 1008;

    final private Receiver mReceiver = new Receiver();
    final private NvAppProfiles mAppProfiles = new NvAppProfiles(this);
    private DisplayManager mDisplayManager;
    private IWindowManager mWindowManager;
    private boolean isTv;

    @Override
    public IBinder onBind(Intent intent) {
        // We don't provide binding, so return null
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        mDisplayManager = (DisplayManager) getSystemService(Context.DISPLAY_SERVICE);
        mWindowManager = IWindowManager.Stub.asInterface(ServiceManager.getService(Context.WINDOW_SERVICE));
        isTv = getPackageManager().hasSystemFeature(PackageManager.FEATURE_LEANBACK);
        mReceiver.init();

        return super.onStartCommand(intent, flags, startId);
    }

    final class Receiver extends BroadcastReceiver {
        private boolean mExternalDisplayConnected = false;
        private int oldDisplayWidth = 1280;
        private int oldDisplayHeight = 720;

        private void setFanProfile(String profile) {
            try {
                final FileOutputStream pwmProfile = new FileOutputStream("/sys/devices/pwm-fan/fan_profile");
                pwmProfile.write(profile.getBytes());
                pwmProfile.close();
                final FileOutputStream estProfile = new FileOutputStream("/sys/devices/thermal-fan-est/fan_profile");
                estProfile.write(profile.getBytes());
                estProfile.close();
            } catch (IOException e) {
                Log.w(TAG, "Failed to update fan profile");
            }
        }

        private void setFanCoeffs(int dev1, int dev2) {
            try {
                final FileOutputStream coeffFile = new FileOutputStream("/sys/devices/thermal-fan-est/coeff");
                coeffFile.write(String.format("[0] %d 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n", dev1).getBytes());
                coeffFile.write(String.format("[1] %d 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\n", dev2).getBytes());
                coeffFile.close();
            } catch (IOException e) {
                Log.w(TAG, "Failed to update fan profile");
            }
        }

        private void updatePowerState(Context context, boolean connected) {
            final SharedPreferences sharedPrefs = context.getSharedPreferences("org.lineageos.settings.device_preferences", context.MODE_PRIVATE);
            final boolean perfMode = sharedPrefs.getBoolean("perf_mode", false);

            if (perfMode) {
                setFanProfile("docked");
                setFanCoeffs(95, 100);

                if (connected) {
                    mAppProfiles.setPowerMode(NvConstants.NV_POWER_MODE_MAX_PERF);
                } else {
                    mAppProfiles.setPowerMode(NvConstants.NV_POWER_MODE_OPTIMIZED);
                }
            } else {
                if (connected) {
                    setFanProfile("docked");
                    setFanCoeffs(95, 100);
                    mAppProfiles.setPowerMode(NvConstants.NV_POWER_MODE_OPTIMIZED);
                } else {
                    setFanProfile("handheld");
                    setFanCoeffs(100, 92);
                    mAppProfiles.setPowerMode(NvConstants.NV_POWER_MODE_BATTERY_SAVER);
                }
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
            final String action = intent.getAction();

            switch (action) {
                case WindowManagerPolicyConstants.ACTION_HDMI_PLUGGED:
                    Log.i(TAG, "HDMI state update");

                    final boolean connected = intent.getBooleanExtra(WindowManagerPolicyConstants.EXTRA_HDMI_PLUGGED_STATE, false);

                    // Force docked display size to avoid apps being forced to the resolution of the internal panel
                    try {
                        if (connected) {
                            if (isTv) {
                                // On ATV always force 1080p for UI when docked, external display also always uses id 0
                                mWindowManager.setForcedDisplaySize(0, 1920, 1080);
                                mWindowManager.setForcedDisplayDensityForUser(0, 320, UserHandle.USER_CURRENT);
                            } else {
                                android.view.Display[] displays = mDisplayManager.getDisplays(DisplayManager.DISPLAY_CATEGORY_PRESENTATION);
                                if (displays == null || displays.length == 0) {
                                    Log.e(TAG, "Failed to get available displays");
                                    return;
                                }
                                final int externalDisplayId = displays[0].getDisplayId();
                                final Point displaySize = new Point();

                                for (int i = 0; i < displays.length; i++)
                                    Log.i(TAG, "Display idx: " + String.valueOf(i) + " id: " + String.valueOf(displays[i].getDisplayId()));

                                // Preserve user/default set built-in display resolution.
                                mWindowManager.getBaseDisplaySize(0, displaySize);
                                oldDisplayWidth = displaySize.x;
                                oldDisplayHeight = displaySize.y;

                                // Scale built-in display to new resolution for smooth transition
                                mWindowManager.getInitialDisplaySize(externalDisplayId, displaySize);
                                mWindowManager.setForcedDisplaySize(0, displaySize.x, displaySize.y);

                                // Set new resolution to external display also.
                                mWindowManager.setForcedDisplaySize(externalDisplayId, displaySize.x, displaySize.y);

                                // Set density based off standard 32" TV (1920x1080 @ 160dpi)
                                mWindowManager.setForcedDisplayDensityForUser(externalDisplayId, 160, UserHandle.USER_CURRENT);
                            }
                        } else {
                            Log.i(TAG, "HDMI disconnected");
                            if (mExternalDisplayConnected) {
                                if (isTv) {
                                    // Restore default resolution and density for built-in display
                                    mWindowManager.clearForcedDisplaySize(0);
                                    mWindowManager.clearForcedDisplayDensityForUser(0, UserHandle.USER_CURRENT);
                                } else {
                                    // Restore user/default resolution back to built-in display
                                    mWindowManager.setForcedDisplaySize(0, oldDisplayWidth, oldDisplayHeight);
                                }
                            } else {
                                // Restore user/default resolution back to built-in display
                                mWindowManager.setForcedDisplaySize(0, oldDisplayWidth, oldDisplayHeight);
                            }
                        }
                    } catch (RemoteException ex) {
                        Log.w(TAG, "Failed to set display resolution");
                    }

                    mExternalDisplayConnected = connected;

                    updatePowerState(context, mExternalDisplayConnected);

                case Intent.ACTION_SCREEN_ON:
                    Log.i(TAG, "Screen on");

                    DisplayUtils.setInternalDisplayState(!mExternalDisplayConnected);

                    // Unlock device automatically if docked and reset res otherwise to work around broken HWC rotation
                    try {
                        if (mExternalDisplayConnected) {
                            mWindowManager.dismissKeyguard(null, null);
                        } else {
                            mWindowManager.clearForcedDisplaySize(0);
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
