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

function play(on, n) {
  for (let i = 1; i <= n; i++) {
    $("#song-".concat(i))[0].pause();
    $("#song-".concat(i))[0].currentTime = 0;
    $("#song-title-".concat(i)).removeClass('font-italic');
  }
  for (let i = 1; i <= n; i++) {
    if (i == on) {
      $("#song-btn-".concat(i)).attr('onclick', 'play(0, '.concat(n).concat(')'));
      $("#song-".concat(i))[0].play();
      $("#song-title-".concat(i)).addClass('font-italic');
    } else {
      $("#song-btn-".concat(i)).attr('onclick', 'play('.concat(i).concat(', ').concat(n).concat(')'));
    }
  }
}


// vim: set ts=2 sw=2 expandtab:
