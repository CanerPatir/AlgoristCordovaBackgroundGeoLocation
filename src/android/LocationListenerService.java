package com.algorist.plugins.LocationListener;

import android.app.IntentService;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.location.LocationManager;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

import java.util.HashMap;

public class LocationListenerService extends Service implements LocationListenerLogger {
    private static final String TAG = "LocationService";
    private static final int LOCATION_INTERVAL = 10000;
    private static final float LOCATION_DISTANCE = 10f;

    private LocationManager mLocationManager = null;
    private boolean isDebug;
    private LocationListener[] mLocationListeners;

    @Override
    public IBinder onBind(Intent arg0) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        Log.e(TAG, "onStartCommand");

        String postUrl;
        HashMap<String, String> headers;

        if (intent != null) {
            postUrl = intent.getStringExtra("postUrl");
            headers = (HashMap<String, String>) intent.getSerializableExtra("headers");
            isDebug = intent.getBooleanExtra("isDebug", false);
        } else {
            LocationConfig lConfig = LocationConfig.fromFile(getApplicationContext());
            if (lConfig != null) {
                postUrl = lConfig.getPostUrl();
                headers = lConfig.getHeaders();
                isDebug = lConfig.isDebug();
            } else {
                toastIfDebug("lConfig null");
                return START_REDELIVER_INTENT;
            }
        }

        toastIfDebug("onStartCommand url:" + postUrl);
        if (mLocationListeners == null) {
            mLocationListeners = new LocationListener[]{
                    new LocationListener(LocationManager.GPS_PROVIDER, postUrl, headers, getBaseContext(), this),
                    new LocationListener(LocationManager.NETWORK_PROVIDER, postUrl, headers, getBaseContext(), this)
            };
        }


        initializeLocationManager();

        try {
            mLocationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, LOCATION_INTERVAL, LOCATION_DISTANCE, mLocationListeners[1]);
            toastIfDebug("servis başladı [Network]");
        } catch (java.lang.SecurityException ex) {
            Log.i(TAG, "fail to request location update, ignore", ex);
        } catch (IllegalArgumentException ex) {
            Log.d(TAG, "network provider does not exist, " + ex.getMessage());
        }
        try {
            mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, LOCATION_INTERVAL, LOCATION_DISTANCE, mLocationListeners[0]);
            toastIfDebug("servis başladı [gps]");
        } catch (java.lang.SecurityException ex) {
            Log.i(TAG, "fail to request location update, ignore", ex);
        } catch (IllegalArgumentException ex) {
            Log.d(TAG, "gps provider does not exist " + ex.getMessage());
        }

//            return START_REDELIVER_INTENT;
        return START_STICKY;
    }

    public void toastIfDebug(String message) {
        if (isDebug) {
            Toast.makeText(getApplicationContext(), message, Toast.LENGTH_SHORT).show();
        }

        Log.i(TAG, message);
    }

//    @Override
//    public void onCreate() {
//        Log.e(TAG, "onCreate");
//        Toast.makeText(getBaseContext(), "servis başladı", Toast.LENGTH_SHORT).show();
//
//        initializeLocationManager();
//
//        try {
//            mLocationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, LOCATION_INTERVAL, LOCATION_DISTANCE, mLocationListeners[1]);
//        } catch (java.lang.SecurityException ex) {
//            Log.i(TAG, "fail to request location update, ignore", ex);
//        } catch (IllegalArgumentException ex) {
//            Log.d(TAG, "network provider does not exist, " + ex.getMessage());
//        }
//        try {
//            mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, LOCATION_INTERVAL, LOCATION_DISTANCE, mLocationListeners[0]);
//        } catch (java.lang.SecurityException ex) {
//            Log.i(TAG, "fail to request location update, ignore", ex);
//        } catch (IllegalArgumentException ex) {
//            Log.d(TAG, "gps provider does not exist " + ex.getMessage());
//        }
//    }

    @Override
    public void onDestroy() {
        toastIfDebug("servis durduruldu");

        super.onDestroy();
        if (mLocationManager != null) {
            for (int i = 0; i < mLocationListeners.length; i++) {
                try {
                    mLocationManager.removeUpdates(mLocationListeners[i]);
                } catch (java.lang.SecurityException ex) {
                    toastIfDebug("fail to request removeUpdates, ignore");
                } catch (Exception ex) {
                    toastIfDebug("fail to remove location listners, ignore");
                }
            }
        }
    }

    private void initializeLocationManager() {
        if (mLocationManager == null) {
            toastIfDebug("initializeLocationManager");
            mLocationManager = (LocationManager) getBaseContext().getSystemService(Context.LOCATION_SERVICE);
        }
    }
}