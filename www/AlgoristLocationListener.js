var exec = require('cordova/exec');

exports.startLocationListener = function(postUrl, headers, isDebug, success, error) {
    exec(success, error, "AlgoristLocationListener", "startLocationListener", [postUrl, headers, isDebug]);
};

exports.stopLocationListener = function (success, error) {
    exec(success, error, "AlgoristLocationListener", "stopLocationListener", []);
};
