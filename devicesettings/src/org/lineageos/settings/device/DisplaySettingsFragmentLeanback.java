/*
 * Copyright (C) 2023-2025 The LineageOS Project
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

import java.util.HashMap;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.RemoteException;
import android.os.SystemProperties;
import android.util.Log;
import android.view.MenuItem;

import androidx.preference.Preference;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceManager;
import androidx.preference.PreferenceScreen;
import androidx.preference.SeekBarPreference;

import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplayMode;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcModeType;
import vendor.nvidia.hardware.graphics.display.V1_0.INvDisplay;

public class DisplaySettingsFragmentLeanback extends PreferenceFragmentCompat
        implements SharedPreferences.OnSharedPreferenceChangeListener {

    private final static String TAG = DisplaySettingsFragmentLeanback.class.getSimpleName();
    public boolean mInModeChange = false;

    private final String sku = SystemProperties.get("ro.product.name", "");
    private INvDisplay mDisplayService;
    private DisplaySettingsPrefsCommon commonPrefs;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        if (!sku.equals("vali")) {
            try {
                mDisplayService = INvDisplay.getService(true /* retry */);
            } catch (RemoteException e) {
                throw new RuntimeException(e);
            }
        }

        addPreferencesFromResource(R.xml.display_panel_leanback);
        PreferenceScreen preferenceScreen = this.getPreferenceScreen();

        createBrightSettings();

        commonPrefs = new DisplaySettingsPrefsCommon(this, mDisplayService, sku);

        commonPrefs.createPerfSettings();

        if (!sku.equals("vali")) {
            commonPrefs.createDisplaySettings(preferenceScreen);
        }

        commonPrefs.createJoyConSettings(preferenceScreen);
    }

    @Override
    public void onResume() {
        super.onResume();
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(getActivity());
        prefs.registerOnSharedPreferenceChangeListener(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(getActivity());
        prefs.unregisterOnSharedPreferenceChangeListener(this);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            getActivity().getOnBackPressedDispatcher().onBackPressed();
            return true;
        }
        return false;
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPrefs, String key) {
        if (!sku.equals("vali")) {
            HashMap<String, Integer> uidMap = DisplayUtils.makeUidMap(mDisplayService);
            if (key.startsWith("mode_")) {
                String hash = key.substring(5);
                int display = uidMap.getOrDefault(hash, -1);

                if (display >= 0) {
                    int modeIndex = Integer.valueOf(sharedPrefs.getString(key, ""));
                    ((DisplaySettingsLeanbackActivity) getActivity()).mReceiver.mBlocked = true;
                    performModeChange(sharedPrefs, key, modeIndex, display);
                }

                return;
            }

            if (key.equals("disable_internal_on_external_connected")) {
                DisplayUtils.setInternalDisplayState(
                        !(((DisplaySettingsLeanbackActivity) getActivity()).mExternalDisplayConnected
                                && sharedPrefs.getBoolean(key, false)));
                return;
            }
        }
    }

    private void performModeChange(SharedPreferences sharedPrefs, String key, int modeIndex,
            int display) {
        try {
            mDisplayService.modeDefaultSetIndex(display, modeIndex);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to set default display mode");
            return;
        }

        DialogInterface.OnClickListener confirmationDialogClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                switch (which) {
                    case DialogInterface.BUTTON_POSITIVE:
                        try {
                            mDisplayService.modeDefaultCommit(display);
                            mDisplayService.modeDefaultStore(display);
                            mDisplayService.modeUpdate(display);
                        } catch (RemoteException e) {
                            Log.e(TAG, "Failed to save default display mode");
                        }
                        break;

                    case DialogInterface.BUTTON_NEGATIVE:
                        try {
                            mDisplayService.modeDefaultRollback(display);
                            mDisplayService.modeUpdate(display);
                        } catch (RemoteException e) {
                            Log.e(TAG, "Failed to rollback display mode");
                        }
                        break;
                }

                HwcSvcDisplayMode currentMode;

                try {
                    currentMode = mDisplayService.getMode(display,
                            HwcSvcModeType.HWC_SVC_MODE_TYPE_CURRENT);
                } catch (RemoteException e) {
                    Log.e(TAG, "Failed to read display mode");
                    ((DisplaySettingsLeanbackActivity) getActivity()).mReceiver.mBlocked = false;
                    getActivity().recreate();
                    return;
                }

                SharedPreferences.Editor editor = sharedPrefs.edit();
                editor.putString(key, String.valueOf(currentMode.index));
                editor.commit();
                ((DisplaySettingsLeanbackActivity) getActivity()).mReceiver.mBlocked = false;
                getActivity().recreate();
            }
        };

        int waitTime = getResources().getInteger(R.integer.mode_confirmation_wait_time);

        AlertDialog.Builder builder = new AlertDialog.Builder(getView().getContext());
        builder.setTitle(R.string.mode_confirmation_title)
                .setPositiveButton(android.R.string.ok, confirmationDialogClickListener)
                .setNegativeButton(android.R.string.cancel, confirmationDialogClickListener)
                .setMessage(getString(R.string.mode_confirmation_summary, waitTime));

        AlertDialog confirmationDialog = builder.create();
        confirmationDialog.show();

        new CountDownTimer(waitTime * 1000, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                if (isAdded()) {
                    confirmationDialog.setMessage(
                            getString(R.string.mode_confirmation_summary,
                                    millisUntilFinished / 1000));
                }
            }

            @Override
            public void onFinish() {
                if (isAdded()) {
                    confirmationDialog.getButton(DialogInterface.BUTTON_NEGATIVE)
                            .performClick();
                }
            }
        }.start();
    }

    private void createBrightSettings() {
        SeekBarPreference brightPref = findPreference("bright_pref");
        int current = DisplayUtils.getPanelBrightness(getActivity().getContentResolver());

        brightPref.setUpdatesContinuously(true);
        brightPref.setShowSeekBarValue(false);
        brightPref.setDefaultValue(current);
        brightPref.setOnPreferenceChangeListener(
                new Preference.OnPreferenceChangeListener() {
                    @Override
                    public boolean onPreferenceChange(Preference preference,
                            Object newValue) {

                        DisplayUtils.setPanelBrightness(getActivity().getContentResolver(), (Integer) newValue);
                        return true;
                    }
                });
    }
}
