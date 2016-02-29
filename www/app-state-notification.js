var exec = require('cordova/exec');

function PluginObject() {

    this.init = function (listener) {
        exec(success, error, 'ApplicationStateNotification', 'init', []);
        
        function success(msg) {
            if (listener) {
                if ( msg && msg.event === 'init' && typeof listener.onInit === 'function' ) {
                    listener.onInit({success: true});
                } 
                if ( msg && msg.event === 'stateChange' && typeof listener.onStateChanged === 'function' ) {
                    listener.onStateChanged(msg.reason);
                } 
                else {
                    error(msg);
                }
            }
        }
        
        function error(msg) {
            if (listener && typeof listener.onError === 'function') {
                listener.onError(msg);
            }
        }
    };

};

module.exports = new PluginObject();
