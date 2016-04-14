/**
 * Created by Caner on 8.04.2016.
 */
package com.algorist.plugins.LocationListener;

import android.content.Context;
import android.location.Location;
import android.os.Bundle;
import android.util.Log;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;


public class LocationListener implements android.location.LocationListener {
    private static final String TAG = "LocationListener";
    private Location mLastLocation;
    private RequestQueue requestQueue = null;
    private String postUrl;
    private LocationListenerLogger logger;
    private HashMap<String, String> headers;
    private static final int TWO_MINUTES = 1000 * 60 * 2;

    public LocationListener(String provider, String postUrl, HashMap<String, String> headers, Context context, LocationListenerLogger logger) {
        Log.e(TAG, "LocationListener " + provider);
        this.postUrl = postUrl;
        this.headers = headers;
        this.logger = logger;
        this.mLastLocation = new Location(provider);
//        this.requestQueue = Volley.newRequestQueue(getBaseContext());
        this.requestQueue = Volley.newRequestQueue(context);
    }

    private static boolean isSameProvider(String provider1, String provider2) {
        if (provider1 == null) {
            return provider2 == null;
        }
        return provider1.equals(provider2);
    }

    private static boolean isBetterLocation(Location location, Location currentBestLocation) {
        if (currentBestLocation == null) {
            // A new location is always better than no location
            return true;
        }

        // Check whether the new location fix is newer or older
        long timeDelta = location.getTime() - currentBestLocation.getTime();
        boolean isSignificantlyNewer = timeDelta > TWO_MINUTES;
        boolean isSignificantlyOlder = timeDelta < -TWO_MINUTES;
        boolean isNewer = timeDelta > 0;

        // If it's been more than two minutes since the current location, use the new location
        // because the user has likely moved
        if (isSignificantlyNewer) {
            return true;
            // If the new location is more than two minutes older, it must be worse
        } else if (isSignificantlyOlder) {
            return false;
        }

        // Check whether the new location fix is more or less accurate
        int accuracyDelta = (int) (location.getAccuracy() - currentBestLocation.getAccuracy());
        boolean isLessAccurate = accuracyDelta > 0;
        boolean isMoreAccurate = accuracyDelta < 0;
        boolean isSignificantlyLessAccurate = accuracyDelta > 200;

        // Check if the old and new location are from the same provider
        boolean isFromSameProvider = isSameProvider(location.getProvider(), currentBestLocation.getProvider());

        // Determine location quality using a combination of timeliness and accuracy
        if (isMoreAccurate) {
            return true;
        } else if (isNewer && !isLessAccurate) {
            return true;
        } else if (isNewer && !isSignificantlyLessAccurate && isFromSameProvider) {
            return true;
        }
        return false;
    }

    @Override
    public void onLocationChanged(Location location) {
        Log.e(TAG, "onLocationChanged: " + location);
//        if (isBetterLocation(location, mLastLocation)) {

        mLastLocation.set(location);
        logger.toastIfDebug("onStatusChanged: lat:" + location.getLatitude() + " lng:" + location.getLongitude());
        postLocation(location.getLatitude(), location.getLongitude());
//        }
    }

    @Override
    public void onProviderDisabled(String provider) {
        Log.e(TAG, "onProviderDisabled: " + provider);
        logger.toastIfDebug("Gps is turned off!! : ");
    }

    @Override
    public void onProviderEnabled(String provider) {
        Log.e(TAG, "onProviderEnabled: " + provider);
        logger.toastIfDebug("Gps is turned on!! : ");
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
        Log.e(TAG, "onStatusChanged: " + provider);
        logger.toastIfDebug("onStatusChanged: " + provider);
    }

    private void postLocation(double lat, double lng) {
        // Request a string response from the provided URL.
        if (postUrl != null && !postUrl.isEmpty()) {
            Map<String, String> params = new HashMap<String, String>();
            params.put("Long", String.valueOf(lng));
            params.put("Lat", String.valueOf(lat));

            LocationListenerJsonRequest jsObjRequest = new LocationListenerJsonRequest(Request.Method.POST, postUrl, params, headers,
                    new Response.Listener<JSONObject>() {
                        @Override
                        public void onResponse(JSONObject response) {
                            logger.toastIfDebug("Http success " + response.toString());
                        }
                    }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {
                    logger.toastIfDebug("Http error " + error.toString());
                }
            });

            requestQueue.add(jsObjRequest);
        } else {
            logger.toastIfDebug("Http could not perform  because url empty");
        }
    }
}