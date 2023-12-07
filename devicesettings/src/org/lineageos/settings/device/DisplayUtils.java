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

import android.content.SharedPreferences;
import android.os.RemoteException;
import android.util.Log;
import android.view.IWindowManager;

import java.io.FileOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.util.HashMap;

import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplay;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplayMode;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplayModePixEnc;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcEdidInfo;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcModeType;
import vendor.nvidia.hardware.graphics.display.V1_0.INvDisplay;

public class DisplayUtils {
    private static final String TAG = DisplayUtils.class.getSimpleName();
    public static final String POWER_UPDATE_INTENT =
                                            "com.lineage.devicesettings.UPDATE_POWER";
    public static final String PANEL_MODE_SYSFS =
                            "/sys/devices/50000000.host1x/tegradc.0/panel_color_mode";
    public static final String PANEL_BRIGHTNESS_SYSFS =
                            "/sys/class/backlight/backlight/brightness";
    public static final String PWM_FAN_PROFILE_SYSFS =
                                                    "/sys/devices/pwm-fan/fan_profile";
    public static final String EST_FAN_PROFILE_SYSFS =
                                            "/sys/devices/thermal-fan-est/fan_profile";
    public static final String INT_DISPLAY_MODE_SYSFS =
                                            "/sys/bus/platform/devices/tegradc.0/enable";

    public static void setInternalDisplayState(boolean state) {
        Log.d(TAG, "setInternalDisplayState: " + String.valueOf(state));
        try {
            FileOutputStream intModeFile =
                            new FileOutputStream(INT_DISPLAY_MODE_SYSFS);
            byte[] buf = new byte[2];

            buf[0] = (byte) (state ? '1' : '0');
            buf[1] = '\n';

            intModeFile.write(buf);
            intModeFile.close();
        } catch (IOException e) {
            Log.w(TAG, "Failed to write display state");
        }
    }

    public static void setDisplayMode(int display, INvDisplay displayService,
                IWindowManager windowManager, SharedPreferences sharedPrefs) {
        int index = 0; // default 0 for internal

        try {
            // grab pref for external displays
            if (display > 0) {
                String displayUid = String.valueOf(DisplayUtils.makeDisplayLabel(
                            displayService.edidGetInfo(display), display).hashCode());
                HwcSvcDisplayMode defMode = displayService.getMode(display,
                                    HwcSvcModeType.HWC_SVC_MODE_TYPE_MAX_1080P_60HZ);

                String modeString = sharedPrefs.getString(("mode_" + displayUid),
                                                        String.valueOf(defMode.index));

                Log.i(TAG, "Setting mode index " + modeString
                                                    + " for display uid " + displayUid);
                index = Integer.parseInt(modeString);
            }

            // manually set hwc mode and force android to update rotation
            displayService.modeSetIndex(display, index);
            windowManager.updateRotation(true, true);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to set mode!");
        }
    }

    public static HashMap<String, Integer> makeUidMap(INvDisplay displayService) {
        HashMap<String, Integer> uidMap = new HashMap<String, Integer>();
        for (int i = HwcSvcDisplay.HWC_SVC_DISPLAY_PANEL;
                        i <= HwcSvcDisplay.HWC_SVC_DISPLAY_HDMI2; i++) {
            try {
                String displayUid = String.valueOf(makeDisplayLabel(
                    displayService.edidGetInfo(i), i).hashCode()); // Unique id for disp
                uidMap.put(displayUid, i);
            } catch (RemoteException e) {
                continue;
            }
        }

        return uidMap;
    }

    public static String makeDisplayLabel(HwcSvcEdidInfo edid, int display) {
        if (!edid.monitor_name.isEmpty())
            // report name from edid if present
            return (edid.manufacturer_id.isEmpty() ? "" :
                (edid.manufacturer_id + " - ")) + edid.monitor_name;
        if (display == HwcSvcDisplay.HWC_SVC_DISPLAY_PANEL)
            return "Internal Panel"; // Most internal panels do not have an edid

        return "Unknown";
    }

    public static String makeModeInfoString(HwcSvcDisplayMode mode) {
        return String.format("%dx%d %sHz", mode.xres, mode.yres,
                new DecimalFormat("###.##").format(mode.refresh));
    }

    public static String makeColorInfoString(HwcSvcDisplayMode mode) {
        String encodingStr = "";
        String colorimetryStr = "";

        switch (mode.pixenc) {
            case HwcSvcDisplayModePixEnc.HWC_SVC_DISP_PIXENC_YUV444:
                encodingStr = "YUV444";
                break;
            case HwcSvcDisplayModePixEnc.HWC_SVC_DISP_PIXENC_YUV422:
                encodingStr = "YUV422";
                break;
            case HwcSvcDisplayModePixEnc.HWC_SVC_DISP_PIXENC_YUV420:
                encodingStr = "YUV420";
                break;
            default:
                encodingStr = "RGB";
                break;
        }

        if (mode.colorimetry != 1)
            colorimetryStr = "Rec. 709";
        else
            colorimetryStr = "Rec. 2020";

        if ((mode.flags & 1) == 1)
            colorimetryStr += " VRR";

        if ((mode.flags & 2) == 1)
            colorimetryStr += " HDR10";

        // Unsupported
        if ((mode.flags & 4) == 1)
            colorimetryStr += " DOVI";

        return String.format("%s %d-bit %s", encodingStr, mode.bpc, colorimetryStr);
    }

    public static void setPanelColorMode(String mode) {
        Log.d(TAG, "OLED panel mode set: " + mode);
        try {
            FileOutputStream colorModeFile = new FileOutputStream(PANEL_MODE_SYSFS);
            byte[] buf = new byte[4];

            buf = mode.getBytes(StandardCharsets.US_ASCII);

            colorModeFile.write(buf);
            colorModeFile.close();
        } catch (IOException e) {
            Log.w(TAG, "Failed to write color mode");
        }
    }

    public static String getPanelColorMode() {
        byte[] buf = new byte[4];
        String out;

        try {
            FileInputStream colorModeFile = new FileInputStream(PANEL_MODE_SYSFS);

            colorModeFile.read(buf);
            out = new String(buf, StandardCharsets.US_ASCII);
            Log.w(TAG, "OLED mode read color mode: " + out);
            colorModeFile.close();
        } catch (IOException e) {
            Log.w(TAG, "Failed to read color mode");
            out = new String("");
        }

        return out;
    }

    public static void setPanelBrightness(int brightness) {
        Log.d(TAG, "Setting brightness: " + brightness);
        try {
            FileOutputStream brightnessFile = new FileOutputStream(PANEL_BRIGHTNESS_SYSFS);
            byte[] buf = new byte[4];

            buf = String.valueOf(brightness).getBytes(StandardCharsets.US_ASCII);

            brightnessFile.write(buf);
            brightnessFile.close();
        } catch (IOException | NumberFormatException e) {
            Log.i(TAG, "Failed to set brightness");
        }
    }

    public static Integer getPanelBrightness() {
        byte[] buf = new byte[4];
        int out;

        try {
            FileInputStream brightnessFile = new FileInputStream(PANEL_BRIGHTNESS_SYSFS);

            brightnessFile.read(buf);
            out = Integer.parseInt(new String(buf, StandardCharsets.US_ASCII));
            Log.i(TAG, "Current brightness: " + out);
            brightnessFile.close();
        } catch (IOException | NumberFormatException e) {
            Log.i(TAG, "Failed to read brightness");
            out = 128;
        }

        return out;
    }

    public static void setFanProfile(String profile) {
        Log.i(TAG, "Setting fan profile: " + profile);
        try {
            final FileOutputStream pwmProfile =
                                new FileOutputStream(PWM_FAN_PROFILE_SYSFS);
            pwmProfile.write(profile.getBytes());
            pwmProfile.close();
            final FileOutputStream estProfile =
                                new FileOutputStream(EST_FAN_PROFILE_SYSFS);
            estProfile.write(profile.getBytes());
            estProfile.close();
        } catch (IOException e) {
            Log.w(TAG, "Failed to update fan profile");
        }
    }
}
