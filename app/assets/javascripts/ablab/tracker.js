var Ablab = (function(scripts) {
  var currentScript = scripts[scripts.length - 1];
  return {
    debug: false,
    baseURL: '/ablab',
    trackView: function(experiment) {
      this._track(experiment, 'view');
    },
    trackSuccess: function(experiment) {
      this._track(experiment, 'success');
    },
    _track: function(experiment, evt) {
      var trackerPath = (this.baseURL) + '/track.js';
      var script = document.createElement('script');
      var param_str = trackerPath + '?experiment=' + experiment + '&event=' + evt;
      window.location.search
        .replace(/[?&]+([^=&]+)=([^&]*)/gi, function(str,key,value) {
          if (key == 'ablab_group') {
            param_str = param_str + ' &ablab_group=' + value;
          }
        }
      );
      script.setAttribute('src', param_str);
      currentScript.parentNode.appendChild(script);
    }
  }
}(document.getElementsByTagName("script")));
