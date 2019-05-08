const setBio = function() {
  const setter = (lang) => {
    $('#bio-content').html($('#bio-content-' + lang).html());
  };
  setter('en');
  return setter;
}();
