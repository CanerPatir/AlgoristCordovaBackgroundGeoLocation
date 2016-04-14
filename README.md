# AlgoristCordovaBackgroundGeoLocation
This is a Apache Cordova plugin that allows of tracking user location and posts location changes to http server.


# Usage

Starting Plugin:
```javascript
 AlgoristLocationListener.startLocationListener(<your_resful_service>
            , <your_headers_if_required>//For Example: { Authorization: 'Bearer asd13821f/Qwer.....'}
            , true //debug mode true false it shows toast if true but on ios do nothing
            , function () {
                console.log('[AlgoristLocationListener] plugin başlatıldı.');
            }, function (err) {
                console.log('[AlgoristLocationListener] plugin başlatılamadı.' + JSON.stringify(err));
            });
```

Stopping Plugin:
```javascript
  AlgoristLocationListener.stopLocationListener(function () {
            console.log('[AlgoristLocationListener] plugin has stopped.');
        }, function (err) {
            console.log('[AlgoristLocationListener] could not be stopped.' + err);
        });
```

