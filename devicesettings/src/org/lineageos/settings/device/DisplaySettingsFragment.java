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

import android.app.ActionBar;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.RemoteException;
import android.util.Log;
import android.view.MenuItem;

import android.app.AlertDialog;
import androidx.preference.ListPreference;
import androidx.preference.PreferenceCategory;
import androidx.preference.PreferenceFragment;
import androidx.preference.PreferenceManager;
import androidx.preference.PreferenceScreen;
import androidx.preference.SwitchPreference;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;

import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplay;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplayMode;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplayType;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcModeType;
import vendor.nvidia.hardware.graphics.display.V1_0.INvDisplay;

public class DisplaySettingsFragment extends PreferenceFragment
        implements SharedPreferences.OnSharedPreferenceChangeListener {

    private static final String TAG = DisplaySettingsFragment.class.getSimpleName();
    public boolean mInModeChange = false;
    private INvDisplay mDisplayService;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        try {
            mDisplayService = INvDisplay.getService(true /* retry */);
        } catch (RemoteException e) {
        }

        addPreferencesFromResource(R.xml.display_panel);
        PreferenceScreen preferenceScreen = this.getPreferenceScreen();

        for (int i = HwcSvcDisplay.HWC_SVC_DISPLAY_PANEL; i <= HwcSvcDisplay.HWC_SVC_DISPLAY_HDMI2; i++) {
            PreferenceCategory category = new PreferenceCategory(preferenceScreen.getContext());

            if (!initializeDisplayCategory(category, i))
                continue;

            preferenceScreen.addPreference(category);
            populateDisplayCategory(category, i);

        }

        final ActionBar actionBar = getActivity().getActionBar();
        actionBar.setDisplayHomeAsUpEnabled(true);
    }

    @Override
    public void onResume() {
        super.onResume();
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(getContext());
        prefs.registerOnSharedPreferenceChangeListener(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(getContext());
        prefs.unregisterOnSharedPreferenceChangeListener(this);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            getActivity().onBackPressed();
            return true;
        }
        return false;
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPrefs, String key) {
        HashMap<String, Integer> uidMap = DisplayUtils.makeUidMap(mDisplayService);
        if (key.startsWith("mode_")) {
            String hash = key.substring(5);
            int display = uidMap.getOrDefault(hash, -1);

            if (display >= 0) {
                int modeIndex = Integer.valueOf(sharedPrefs.getString(key, ""));
                ((DisplaySettingsActivity)getActivity()).mReceiver.mBlocked = true;
                performModeChange(sharedPrefs, key, modeIndex, display);
            }

            return;
        }

        if (key.equals("disable_internal_on_external_connected")) {
            DisplayUtils.setInternalDisplayState(!(((DisplaySettingsActivity)getActivity()).mExternalDisplayConnected && sharedPrefs.getBoolean(key, false)));
            return;
        }
    }

    private void performModeChange(SharedPreferences sharedPrefs, String key, int modeIndex, int display) {
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
                        } catch (RemoteException e) {
                            Log.e(TAG, "Failed to save default display mode");;
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
                    currentMode = mDisplayService.getMode(display, HwcSvcModeType.HWC_SVC_MODE_TYPE_CURRENT);
                } catch (RemoteException e) {
                    Log.e(TAG, "Failed to read display mode");
                    ((DisplaySettingsActivity)getActivity()).mReceiver.mBlocked = false;
                    getActivity().recreate();
                    return;
                }

                SharedPreferences.Editor editor = sharedPrefs.edit();
                editor.putString(key, String.valueOf(currentMode.index));
                editor.commit();
                ((DisplaySettingsActivity)getActivity()).mReceiver.mBlocked = false;
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
                if (confirmationDialog != null && isAdded())
                    confirmationDialog.setMessage(getString(R.string.mode_confirmation_summary, millisUntilFinished / 1000));
            }

            @Override
            public void onFinish() {
                if (confirmationDialog != null && isAdded())
                    confirmationDialog.getButton(DialogInterface.BUTTON_NEGATIVE).performClick();
            }
        }.start();
    }

    private boolean initializeDisplayCategory(PreferenceCategory category, int display) {
        try {
            int type = mDisplayService.displayGetType(display);
            ArrayList<HwcSvcDisplayMode> availableModes = mDisplayService.modeGetList(display);

            if (availableModes.size() == 0)
                return false; // Display is not connected

            category.setTitle(DisplayUtils.makeDisplayLabel(mDisplayService.edidGetInfo(display), display));
            category.setSummary(HwcSvcDisplayType.toString(type));
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to read display info");
            return false;
        }

        return true;
    }

    private void populateDisplayCategory(PreferenceCategory category, int display) {
        String displayUid;
        HwcSvcDisplayMode currentMode;
        ArrayList<HwcSvcDisplayMode> availableModes;

        try {
            displayUid = String.valueOf(DisplayUtils.makeDisplayLabel(mDisplayService.edidGetInfo(display), display).hashCode());
            currentMode = mDisplayService.getMode(display, HwcSvcModeType.HWC_SVC_MODE_TYPE_CURRENT);
            availableModes = mDisplayService.modeGetList(display);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to read display info");
            return;
        }

        // Sort by resolution and refresh rate
        Collections.sort(availableModes, new Comparator() {
            public int compare(Object a, Object b) {
                HwcSvcDisplayMode modeA = (HwcSvcDisplayMode) a;
                HwcSvcDisplayMode modeB = (HwcSvcDisplayMode) b;

                if (modeA.xres == modeB.xres) {
                    if (modeA.yres == modeB.yres) {
                        if (modeA.refresh == modeB.refresh)
                            return 0;
                        else if (modeA.refresh > modeB.refresh)
                            return -1;
                        else
                            return 1;
                    } else if (modeA.yres > modeB.yres) {
                        return -1;
                    } else {
                        return 1;
                    }
                } else if (modeA.xres > modeB.xres) {
                    return -1;
                } else {
                    return 1;
                }
            }
        });

        ListPreference modesPreference = new ListPreference(category.getContext());
        ArrayList<String> displayedModes = new ArrayList<String>();
        ArrayList<String> modeIndices = new ArrayList<String>();

        availableModes.forEach((mode) -> displayedModes.add(DisplayUtils.makeModeInfoString(mode) + " " + DisplayUtils.makeColorInfoString(mode)));
        availableModes.forEach((mode) -> modeIndices.add(String.valueOf(mode.index)));

        modesPreference.setEntries(displayedModes.toArray(new CharSequence[displayedModes.size()]));
        modesPreference.setEntryValues(modeIndices.toArray(new CharSequence[modeIndices.size()]));
        modesPreference.setTitle(R.string.mode_selection_title);
        modesPreference.setSummary(DisplayUtils.makeModeInfoString(currentMode) + "\n" + DisplayUtils.makeColorInfoString(currentMode));
        modesPreference.setKey("mode_" + displayUid);
        modesPreference.setValue(String.valueOf(currentMode.index));

        category.addPreference(modesPreference);

        // Show checkbox to disable internal panel when an external display is connected
        if (display == HwcSvcDisplay.HWC_SVC_DISPLAY_PANEL) {
            SwitchPreference disableInternalOnExternalConnectedPreference = new SwitchPreference(category.getContext());
            disableInternalOnExternalConnectedPreference.setTitle(R.string.disable_internal_on_external_connected_title);
            disableInternalOnExternalConnectedPreference.setSummaryOn(R.string.disable_internal_on_external_connected_summary_on);
            disableInternalOnExternalConnectedPreference.setSummaryOff(R.string.disable_internal_on_external_connected_summary_off);
            disableInternalOnExternalConnectedPreference.setKey("disable_internal_on_external_connected");

            category.addPreference(disableInternalOnExternalConnectedPreference);
        }
    }
}
