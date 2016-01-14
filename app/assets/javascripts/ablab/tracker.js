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
      script.setAttribute('src', trackerPath + '?experiment=' + experiment + '&event=' + evt);
      currentScript.parentNode.appendChild(script);
    }
  }
}(document.getElementsByTagName("script")));
