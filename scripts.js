$(document).ready(function() {
  function translate(lang) {
    $("#lang-".concat(lang)).click(function() {
      $.getJSON("?action=get-i18n&lang=".concat(lang), function(data) {
          for (var key in data)
          {
            $("#i18n-".concat(key)).html(data[key]);
          }
      });
    });
  }
  ["en", "it"].forEach(lang => {
    translate(lang);
  });
});
