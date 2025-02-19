package org.lineageos.settings.device;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.hardware.nintendo.joycond.IJoycond;
import android.hardware.nintendo.joycond.KeyMap;
import android.os.IBinder;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.os.SystemProperties;
import android.util.Log;

import androidx.preference.ListPreference;
import androidx.preference.Preference;
import androidx.preference.PreferenceCategory;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceGroup;
import androidx.preference.PreferenceManager;
import androidx.preference.PreferenceScreen;
import androidx.preference.SeekBarPreference;
import androidx.preference.SwitchPreference;

import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplay;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplayMode;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcDisplayType;
import vendor.nvidia.hardware.graphics.display.V1_0.HwcSvcModeType;
import vendor.nvidia.hardware.graphics.display.V1_0.INvDisplay;

public class DisplaySettingsPrefsCommon {
    private static final String TAG = DisplaySettingsPrefsCommon.class.getSimpleName();
    public static final String JOYCOND_ANALOG_PROP = "persist.vendor.joycond.analog";
    public static final String JOYCOND_COMBINED_PROP = "persist.vendor.joycond.combined";
    public static final String JOYCOND_RSMOUSE_PROP = "persist.vendor.joycond.rsmouse";
    public static final String JOYCOND_SENSE_X_PROP = "persist.vendor.joycond.mouse_sense.x";
    public static final String JOYCOND_SENSE_Y_PROP = "persist.vendor.joycond.mouse_sense.y";
    public static final String JOYCOND_DEAD_X_PROP = "persist.vendor.joycond.mouse_dead.y";
    public static final String JOYCOND_DEAD_Y_PROP = "persist.vendor.joycond.mouse_dead.y";

    public static final float JOYCON_SENSE_MULTIPLIER = 10000f;
    public static final String JOYCON_SENSE_DEFAULT = "0.0003";
    public static final float JOYCON_DEAD_MULTIPLIER = 10f;
    public static final String JOYCON_DEAD_DEFAULT = "1";

    private PreferenceFragmentCompat fragment;
    private Activity activity;
    private Resources res;
    private INvDisplay mDisplayService;
    private String sku;
    private IJoycond mJoycond;

    public DisplaySettingsPrefsCommon(PreferenceFragmentCompat fragment,
            INvDisplay mDisplayService, String sku) {

        this.fragment = fragment;
        this.res = fragment.getResources();
        this.activity = fragment.getActivity();
        this.sku = sku;
        this.mDisplayService = mDisplayService;

        IBinder binder = ServiceManager.getService(IJoycond.DESCRIPTOR + "/default");
        if (binder != null) {
            mJoycond = IJoycond.Stub.asInterface(binder);
        } else {
            Log.e(TAG, "Failed to get Joycond service");
        }
    }

    public void createJoyConSettings(PreferenceScreen preferenceScreen) {
        int index;
        boolean analog = true;
        boolean rsmouse = true;
        float mouseSense = 0;
        float mouseDead = 0;
        final List<KeyMap> mapping;

        if (mJoycond == null) {
            Log.w(TAG, "Joycond instance is null, skipping JoyCon settings creation...");
            return;
        }

        // Analog trigger preference
        SwitchPreference analogPref = fragment.findPreference("joycon_analog");

        if (analogPref == null) {
            Log.e(TAG, "No preference with key joycon_analog found! Skipping JoyCon settings creation...");
            return;
        }

        PreferenceGroup group = analogPref.getParent();

        try {
            analog = mJoycond.getAnalog();
        } catch (RemoteException e) {
            Log.w(TAG, "Could not get analog preference! Inferring from prop...");
            analog = SystemProperties.getBoolean(JOYCOND_ANALOG_PROP, true);
        }

        Log.i(TAG, "Joycond current analog value: " + String.valueOf(analog));
        analogPref.setChecked(analog);

        analogPref.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                try {
                    mJoycond.setAnalog((boolean) newValue);
                } catch (RemoteException e) {
                    Log.w(TAG, "Could not set analog preference! Setting prop and deferring...");
                    SystemProperties.set(JOYCOND_ANALOG_PROP, (boolean) newValue ? "1" : "0");
                }
                return true;
            }
        });

        // RSMouse preference
        SwitchPreference rsmousePref = fragment.findPreference("joycon_rsmouse");

        if (rsmousePref == null) {
            Log.e(TAG, "No preference with key joycon_rsmouse found! Skipping rest of JoyCon settings creation...");
            return;
        }

        try {
            rsmouse = mJoycond.getRsmouse();
        } catch (RemoteException e) {
            Log.w(TAG, "Could not get rsmouse preference! Inferring from prop...");
            rsmouse = SystemProperties.getBoolean(JOYCOND_RSMOUSE_PROP, true);
        }

        Log.i(TAG, "Joycond current rsmouse value: " + String.valueOf(rsmouse));
        rsmousePref.setChecked(analog);

        rsmousePref.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                try {
                    mJoycond.setRsmouse((boolean) newValue);
                } catch (RemoteException e) {
                    Log.w(TAG, "Could not set rsmouse preference! Setting prop and deferring...");
                    SystemProperties.set(JOYCOND_RSMOUSE_PROP, (boolean) newValue ? "1" : "0");
                }
                return true;
            }
        });

        // RSMouse sense preference
        SeekBarPreference mouseSensePref = fragment.findPreference("joycon_rsmouse_sense");

        if (mouseSensePref == null) {
            Log.e(TAG, "No preference with key joycon_rsmouse_sense found! " \
                    "Skipping rest of JoyCon settings creation...");
            return;
        }

        // assume X and Y are same, go by X otherwise
        mouseSense = Float.parseFloat(SystemProperties.get(JOYCOND_SENSE_X_PROP, JOYCON_SENSE_DEFAULT));

        Log.i(TAG, "Joycond current sense (x) value: " + String.valueOf(mouseSense));
        mouseSensePref.setValue((int)(JOYCON_SENSE_MULTIPLIER * mouseSense));

        mouseSensePref.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object newValue) {
                String sense = String.valueOf((int)newValue / JOYCON_SENSE_MULTIPLIER);
                SystemProperties.set(JOYCOND_SENSE_X_PROP, sense);
                SystemProperties.set(JOYCOND_SENSE_Y_PROP, sense);
                return true;
            }
        });

        // RSMouse dead preference
        SeekBarPreference mouseDeadPref = fragment.findPreference("joycon_rsmouse_deadzone");

        if (mouseDeadPref == null) {
            Log.e(TAG, "No preference with key joycon_rsmouse_deadzone found! " \
                    "Skipping rest of JoyCon settings creation...");
            return;
        }

        // assume X and Y are same, go by X otherwise
        mouseDead = Float.parseFloat(SystemProperties.get(JOYCOND_DEAD_X_PROP, JOYCON_DEAD_DEFAULT));

        Log.i(TAG, "Joycond current dead (x) value: " + String.valueOf(mouseDead));
        mouseDeadPref.setValue((int)(JOYCON_DEAD_MULTIPLIER * mouseDead));

        mouseDeadPref.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {

            public boolean onPreferenceChange(Preference preference, Object newValue) {
                String dead = String.valueOf((int)newValue / JOYCON_DEAD_MULTIPLIER);
                SystemProperties.set(JOYCOND_DEAD_X_PROP, dead);
                SystemProperties.set(JOYCOND_DEAD_Y_PROP, dead);
                return true;
            }
        });

        // Controller mapping

        try {
            mapping = mJoycond.getLayout();
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to get mapping!");
            return;
        }

        // retrieve keys and mapped key names
        final String[] keys = res.getStringArray(R.array.keys);
        final String[] keysMap = res.getStringArray(R.array.keys_map);

        // set up pref per key
        for (index = 0; index < keys.length; index++) {
            ListPreference pref = new ListPreference(group.getContext());

            // key the preference from the index, indices will remain in sync
            pref.setKey("joycon_map_" + String.valueOf(index));
            pref.setTitle(keysMap[index]);

            // get key name from index
            int toIndex;
            for (toIndex = 0; toIndex < keys.length; toIndex++) {
                if (Integer.parseInt(keys[toIndex]) == mapping.get(index).to)
                    break;
            }
            pref.setSummary("Current value: " + keysMap[toIndex]);
            pref.setValue(keys[toIndex]);

            // options should be the key namaes
            pref.setEntries(keysMap);
            pref.setEntryValues(keys);

            pref.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
                @Override
                public boolean onPreferenceChange(Preference preference, Object newValue) {
                    final List<KeyMap> mapping;

                    // get again to handle changes
                    try {
                        mapping = mJoycond.getLayout();
                    } catch (RemoteException e) {
                        Log.e(TAG, "Failed to get mapping!");
                        return false;
                    }

                    // copy mapping
                    List<KeyMap> newMap = new ArrayList<KeyMap>(mapping);

                    // retrieve mapping index of this preference
                    int indexKey = Integer.parseInt(preference.getKey().substring(11));

                    // construct keymap and set
                    KeyMap change = new KeyMap();
                    change.from = Integer.parseInt(keys[indexKey]);

                    Log.w(TAG, "from: " + keys[indexKey] + " to: " + (String) newValue);

                    change.to = Integer.parseInt((String) newValue);

                    newMap.set(indexKey, change);

                    // get key name from index
                    int toIndex;
                    for (toIndex = 0; toIndex < keys.length; toIndex++) {
                        if (keys[toIndex].equals((String) newValue))
                            break;
                    }
                    pref.setSummary("Current value: " + keysMap[toIndex]);

                    for (KeyMap km : newMap) {
                        Log.w(TAG, "KeyMap Entry: from=" + km.from + ", to=" + km.to);
                    }

                    try {
                        mJoycond.setLayout(newMap);
                    } catch (RemoteException e) {
                        Log.e(TAG, "Failed to set layout!");
                        return false;
                    }
                    return true;
                }
            });

            group.addPreference(pref);
        }
    }

    public void createPerfSettings() {
        SwitchPreference perfPreference = fragment.findPreference("perf_mode");

        perfPreference.setOnPreferenceChangeListener(
                new Preference.OnPreferenceChangeListener() {
                    @Override
                    public boolean onPreferenceChange(Preference preference, Object newValue) {
                        if (((Boolean) newValue) != PreferenceManager
                                .getDefaultSharedPreferences(activity)
                                .getBoolean("perf_mode", false)) {

                            final boolean isEnabled = (Boolean) newValue;
                            if (isEnabled) {
                                new AlertDialog.Builder(activity)
                                        .setTitle(R.string.perf_warning_title)
                                        .setMessage(R.string.perf_warning_summary)
                                        .setNegativeButton(android.R.string.cancel,
                                                new DialogInterface.OnClickListener() {
                                                    @Override
                                                    public void onClick(DialogInterface dialog,
                                                            int whichButton) {
                                                    }
                                                })
                                        .setPositiveButton(android.R.string.ok,
                                                new DialogInterface.OnClickListener() {
                                                    @Override
                                                    public void onClick(DialogInterface dialog,
                                                            int whichButton) {
                                                        SharedPreferences sharedPrefs = PreferenceManager
                                                                .getDefaultSharedPreferences(activity);
                                                        SharedPreferences.Editor editor = sharedPrefs.edit();
                                                        editor.putBoolean("perf_mode", true);
                                                        editor.commit();
                                                        perfPreference.setChecked(true);
                                                    }
                                                })
                                        .setOnDismissListener(
                                                new DialogInterface.OnDismissListener() {
                                                    @Override
                                                    public void onDismiss(DialogInterface dialog) {
                                                        Intent intent = new Intent(DisplayUtils.POWER_UPDATE_INTENT);
                                                        activity.sendBroadcast(intent);
                                                    }
                                                })
                                        .create().show();
                                return false;
                            }
                        }
                        Intent intent = new Intent(DisplayUtils.POWER_UPDATE_INTENT);
                        activity.sendBroadcast(intent);
                        return true;
                    }
                });
    }

    private void createPanelModeSettings(PreferenceCategory category) {
        ListPreference panelColorPref = new ListPreference(category.getContext());
        String current = DisplayUtils.getPanelColorMode();
        int index;

        String[] modes = res.getStringArray(R.array.panel_modes);
        String[] modeMap = res.getStringArray(R.array.panel_mode_map);

        for (index = 0; index < modes.length; index++) {
            if (current.equals(modes[index]))
                break;
        }

        if (index == modes.length) {
            Log.e(TAG, "Unsupported OLED panel mode! ID: " + current);
        } else {

            Log.w(TAG, "OLED Panel Mode Index: " + String.valueOf(index));

            panelColorPref.setKey("panel_color_mode");
            panelColorPref.setTitle(R.string.panel_color_setting_title);
            panelColorPref.setEntries(R.array.panel_mode_map);
            panelColorPref.setEntryValues(R.array.panel_modes);
            panelColorPref.setValue(current);
            panelColorPref.setSummary(modeMap[index]);

            panelColorPref.setOnPreferenceChangeListener(
                    new Preference.OnPreferenceChangeListener() {
                        @Override
                        public boolean onPreferenceChange(Preference preference,
                                Object newValue) {
                            int newIndex;

                            DisplayUtils.setPanelColorMode((String) newValue);

                            for (newIndex = 0; newIndex < modes.length; newIndex++) {
                                if (((String) newValue).equals(modes[newIndex])) {
                                    panelColorPref.setSummary(modeMap[newIndex]);
                                    break;
                                }
                            }
                            return true;
                        }
                    });
        }
    }

    public void createDisplaySettings(PreferenceScreen preferenceScreen) {
        if (mDisplayService == null) {
            Log.e(TAG, "Display service is null! Skipping display settings creation.");
            return;
        }

        for (int i = HwcSvcDisplay.HWC_SVC_DISPLAY_PANEL; i <= HwcSvcDisplay.HWC_SVC_DISPLAY_HDMI2; i++) {
            PreferenceCategory category = new PreferenceCategory(
                    preferenceScreen.getContext());

            if (!initializeDisplayCategory(category, i))
                continue;

            preferenceScreen.addPreference(category);
            populateDisplayCategory(category, i);

        }
    }

    private boolean initializeDisplayCategory(PreferenceCategory category,
            int display) {
        try {
            int type = mDisplayService.displayGetType(display);
            ArrayList<HwcSvcDisplayMode> availableModes = mDisplayService
                    .modeGetList(display);

            if (availableModes.size() == 0)
                return false; // Display is not connected

            category.setTitle(DisplayUtils.makeDisplayLabel(mDisplayService
                    .edidGetInfo(display), display));
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
            displayUid = String.valueOf(DisplayUtils.makeDisplayLabel(mDisplayService
                    .edidGetInfo(display), display).hashCode());
            currentMode = mDisplayService.getMode(display,
                    HwcSvcModeType.HWC_SVC_MODE_TYPE_CURRENT);
            availableModes = mDisplayService.modeGetList(display);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to read display info");
            return;
        }

        // Sort by resolution and refresh rate
        Collections.sort(availableModes, (Comparator<HwcSvcDisplayMode>) (a, b) -> {
            HwcSvcDisplayMode modeA = (HwcSvcDisplayMode) a;
            HwcSvcDisplayMode modeB = (HwcSvcDisplayMode) b;

            if (modeA.xres == modeB.xres) {
                if (modeA.yres == modeB.yres) {
                    if (modeA.refresh == modeB.refresh) {
                        if (modeA.flags > modeB.flags)
                            return -1;
                        else if (modeA.flags < modeB.flags)
                            return 1;
                        else
                            return 0;
                    } else if (modeA.refresh > modeB.refresh)
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
        });

        ListPreference modesPreference = new ListPreference(category.getContext());
        ArrayList<String> displayedModes = new ArrayList<>();
        ArrayList<String> modeIndices = new ArrayList<>();

        availableModes.forEach((mode) -> displayedModes.add(DisplayUtils
                .makeModeInfoString(mode) + " " + DisplayUtils.makeColorInfoString(mode)));
        availableModes.forEach((mode) -> modeIndices.add(String.valueOf(mode.index)));

        modesPreference.setEntries(displayedModes.toArray(
                new CharSequence[displayedModes.size()]));
        modesPreference.setEntryValues(modeIndices.toArray(
                new CharSequence[modeIndices.size()]));
        modesPreference.setTitle(R.string.mode_selection_title);
        modesPreference.setSummary(DisplayUtils.makeModeInfoString(currentMode) + "\n"
                + DisplayUtils.makeColorInfoString(currentMode));
        modesPreference.setKey("mode_" + displayUid);
        modesPreference.setValue(String.valueOf(currentMode.index));

        category.addPreference(modesPreference);

        // Show checkbox to disable internal panel when an external display is connected
        if (display == HwcSvcDisplay.HWC_SVC_DISPLAY_PANEL) {
            SwitchPreference disableInternalOnExternalConnectedPreference = new SwitchPreference(category.getContext());
            disableInternalOnExternalConnectedPreference
                    .setTitle(R.string.disable_internal_on_external_connected_title);
            disableInternalOnExternalConnectedPreference
                    .setSummaryOn(R.string.disable_internal_on_external_connected_summary_on);
            disableInternalOnExternalConnectedPreference
                    .setSummaryOff(R.string.disable_internal_on_external_connected_summary_off);
            disableInternalOnExternalConnectedPreference
                    .setKey("disable_internal_on_external_connected");

            category.addPreference(disableInternalOnExternalConnectedPreference);

            if (sku.equals("fric")) {
                createPanelModeSettings(category);
            }
        }
    }
}
