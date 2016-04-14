package com.algorist.plugins.LocationListener;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

/**
 * This class echoes a string called from JavaScript.
 */
public class AlgoristLocationListenerPlugin extends CordovaPlugin {
    private static final int LOCATION_PERMISSION_REQUEST = 111;
    private CallbackContext callbackContext;
    private Intent locationServiceIntent;
    private String postUrl;
    private Boolean isDebug;
    private HashMap<String, String> headersMap;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        if (action.equals("startLocationListener")) {
            this.postUrl = args.getString(0);
            JSONObject headers = args.getJSONObject(1);
            this.headersMap = new HashMap<String, String>();
            for (Iterator<String> iter = headers.keys(); iter.hasNext(); ) {
                String key = iter.next();
                headersMap.put(key, headers.getString(key));
            }

            this.isDebug = args.getBoolean(2);
            this.startLocationListener();
            return true;
        } else if (action.equals("stopLocationListener")) {
            this.stopLocationListener();
            return true;
        }
        return false;
    }

    private void startLocationListener() {
        if (Build.VERSION.SDK_INT >= 23) {
            ArrayList<String> permissions = new ArrayList<String>();
            if (ContextCompat.checkSelfPermission(cordova.getActivity(), android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(android.Manifest.permission.ACCESS_COARSE_LOCATION);
            }

            if (ContextCompat.checkSelfPermission(cordova.getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(android.Manifest.permission.ACCESS_FINE_LOCATION);
            }

            if (!permissions.isEmpty()) {
                String[] permissionsArr = new String[permissions.size()];
                permissionsArr = permissions.toArray(permissionsArr);

                ActivityCompat.requestPermissions(cordova.getActivity(), permissionsArr, LOCATION_PERMISSION_REQUEST);
            } else {
                startService();
            }
        } else {
            startService();
        }
    }

    private void startService() {
        if (postUrl != null && postUrl.length() > 0) {
            locationServiceIntent = new Intent(cordova.getActivity(), LocationListenerService.class);
            locationServiceIntent.addFlags(Intent.FLAG_FROM_BACKGROUND);
            locationServiceIntent.putExtra("postUrl", postUrl);
            locationServiceIntent.putExtra("headers", headersMap);
            locationServiceIntent.putExtra("isDebug", isDebug);

            LocationConfig lConfig = new LocationConfig(postUrl, headersMap, isDebug);
            lConfig.toFile(cordova.getActivity().getApplicationContext());
            cordova.getActivity().getBaseContext().startService(locationServiceIntent);
            callbackContext.success();
        } else {
            callbackContext.error("Servis başlatılamadı. postUrl non-empty string argument.");
        }
    }

    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, int[] grantResults) throws JSONException {
        super.onRequestPermissionResult(requestCode, permissions, grantResults);
        if (requestCode == LOCATION_PERMISSION_REQUEST) {
            if (grantResults.length > 0) {
                // permission was granted, yay! Do the
                // contacts-related task you need to do.
                startService();
            } else {
                callbackContext.error("Lokasyon izinleri mevcut değil.");
            }
        }
    }

    private void stopLocationListener() {
        try {
            cordova.getActivity().getBaseContext().stopService(locationServiceIntent);
            callbackContext.success();
        } catch (Exception ex) {
            callbackContext.error("Servis durdurulamadı.");
        }
    }
}
