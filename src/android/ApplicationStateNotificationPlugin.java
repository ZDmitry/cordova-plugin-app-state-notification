package com.cordova.zdmitry.appstatenotification;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import android.os.Handler;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


public class ApplicationStateNotificationPlugin extends CordovaPlugin {
    static String TAG = "ApplicationStateNotificationPlugin";

    private Handler  mHandler;
    private Runnable mStatusChecker;

    private CallbackContext m_cbContext = null;
    private Boolean  isLocked = false;

    public void pluginInitialize() {
        registerBroadcastReceiver();
    }

    @Override
    public void onPause(boolean m) {
        super.onPause(m);

        mStatusChecker = new Runnable() {
            @Override
            public void run() {
                try {
                    JSONObject obj = new JSONObject();
                    obj.put("event", "stateChange");
                    if (isLocked) {
                        obj.put("reason", "lock");
                        // Log.v(TAG, "lock");
                    } else {
                        obj.put("reason", "home");
                        // Log.v(TAG, "home");
                    }

                    if (m_cbContext != null) {
                        PluginResult result = new PluginResult(PluginResult.Status.OK, obj);
                        result.setKeepCallback(true);
                        m_cbContext.sendPluginResult(result);
                    }
                } catch (JSONException e) {
                    throw new Error(e);
                }
            }
        };

        mHandler = new Handler();
        mHandler.postDelayed(mStatusChecker, 1000 * 5); // 5 seconds
    }

    @Override
    public void onResume(boolean m) {
        super.onResume(m);

        isLocked = false;
        if (mHandler != null) {
            mHandler.removeCallbacks(mStatusChecker);
            mStatusChecker = null;
            mHandler = null;
        }
    }


    private void registerBroadcastReceiver() {
        final IntentFilter theFilter = new IntentFilter();
        /** System Defined Broadcast */
        theFilter.addAction(Intent.ACTION_SCREEN_ON);
        theFilter.addAction(Intent.ACTION_SCREEN_OFF);

        BroadcastReceiver screenOnOffReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String strAction = intent.getAction();

                if (strAction.equals(Intent.ACTION_SCREEN_OFF)) {
                    isLocked = true;
                } else if (strAction.equals(Intent.ACTION_SCREEN_ON)) {
                    isLocked = false;
                }

            }
        };

        cordova.getActivity().getApplicationContext().registerReceiver(screenOnOffReceiver, theFilter);
    }

    public boolean execute( String action, final JSONArray args, final CallbackContext callbackContext ) throws JSONException {

        if (action.equals("init")) {
            m_cbContext = callbackContext;

            try {
                JSONObject obj = new JSONObject();
                obj.put("event", "init");

                PluginResult result = new PluginResult(PluginResult.Status.OK, obj);
                result.setKeepCallback(true);
                m_cbContext.sendPluginResult(result);
            } catch (JSONException e) {
                throw new Error(e);
            }

            return true;
        }

        return false;
    }
}
