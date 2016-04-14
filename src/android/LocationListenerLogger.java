package com.algorist.plugins.LocationListener;

/**
 * Created by Caner on 6.04.2016.
 */
public interface LocationListenerLogger {
    boolean isDebug = false;
    void toastIfDebug(String message);
}
