const setBio = function() {
  const setter = (lang) => {
    $('#bio-content').html($('#bio-content-' + lang).html());
  };
  setter('en');
  return setter;
}();

/* Filter events so that only future ones are displayed */
(function() {
  const now = new Date().toJSON().slice(0, 10);
  $('.event-row').each(function(index, value) {
    const eventNode = value.cells.item(0);
    if (eventNode.textContent < now) {
      $(this).addClass("d-none");
    }
  });
}());

/* vim: set ts=2 sw=2 expandtab: */
