package com.algorist.plugins.LocationListener;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * Created by Caner on 10.04.2016.
 */
public class LocationListenerBootReceiver  extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            Intent myIntent = new Intent(context, LocationListenerService.class);
            context.startService(myIntent);
        }
}
