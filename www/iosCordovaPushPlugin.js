
var exec = require('cordova/exec');
var PushAPI = {}

PushAPI.initPushMethod = function (arg0, success, error) {
    exec(success, error, 'iosCordovaPushPlugin', 'initPushMethod', [arg0]);
};
PushAPI.receiveMessage = function(arg0, success, error) {
    exec(success, error, "iosCordovaPushPlugin", "receiveMessage", [arg0]);
};

module.exports = PushAPI;