# AlgoristCordovaBackgroundGeoLocation
This is an Apache Cordova plugin that allows of tracking user location and posts location changes to server.


# Usage

Starting Plugin:
```javascript
 AlgoristLocationListener.startLocationListener(<your_restful_service_address>
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

