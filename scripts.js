$(document).ready(function() {
  ["en", "it"].forEach(lang => {
    $("#lang-".concat(lang)).click(function() {
      $.getJSON("?action=get-i18n&lang=".concat(lang), function(data) {
        for (var key in data)
        {
          $("#i18n-".concat(key)).html(data[key]);
        }
      });
    });
  });
});

// vim: set ts=2 sw=2 expandtab:
