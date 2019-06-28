function setBio(lang) {
  $('#bio-content').html($('#bio-content-' + lang).html());
};

/* Filter events so that only future ones are displayed */
function filterEvents() {
  const now = new Date().toJSON().slice(0, 10);
  const months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];

  $('.event-row').each(function(index, value) {
    const eventNode = value.cells.item(0);
    if (eventNode.textContent < now) {
      $(this).addClass("d-none");
    } else {
      const d = eventNode.textContent; /* yyyy-mm-dd */
      eventNode.textContent = 
        parseInt(d.substring(8, 10), 10).toString() + " " +
        months[parseInt(d.substring(5, 7), 10) - 1] + " " +
        d.substring(0, 4);
    }
  });
};

$(function() {
  setBio('en');
  filterEvents();
});

/* vim: set ts=2 sw=2 expandtab: */
