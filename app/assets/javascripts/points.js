function calculatePoints(idstart) {
  var start = moment($('#' + idstart + '_start_at_date').val() + ' ' + $('#' + idstart + '_start_at').val(), 'YYYY-MM-DD HH:mm');
  var endtime = moment($('#' + idstart + '_end_at_date').val() + ' ' + $('#' + idstart + '_end_at').val(), 'YYYY-MM-DD HH:mm');


  // get time difference in hour and validate as well
  var duration = moment.duration(endtime.diff(start));
  // figure out how much of each time belongs to the three prices
  var base = calcSpan(start, endtime)
  //  get any additional times for new total
  if ($('#' + idstart + '_room_needed').val() == "2") {
    base *= 0.6;
  } else if ($('#' + idstart + '_room_needed').val() == "3") {
    base *= 1.3;
  }

  // discount for allowing others to be there
  if ($('#' + idstart + '_allow_others').is(":checked") && $('#' + idstart + '_room_needed').val() != "2") {
    base *= 0.75;
  }
  var returned = check_additionals();
  var base_totaled = parseInt(base) + parseInt(returned.reduce((a, b) => a + b, 0))
  // discount for room needed


  $('#initial_time_length').html(endtime.preciseDiff(start) + '<Br />' + parseInt(base) + " base points needed")
  $('#points_total').html(parseInt(base_totaled))
  $('#idea_points_needed').val(parseInt(base_totaled))
  
  //  check prices are different
  if ($('#' + idstart + '_price_public').val()) {
    if (parseInt($('#' + idstart + '_price_public').val()) > 0 ) {
      if ($('#' + idstart + '_price_stakeholders').val()) {
        if (parseInt($('#' + idstart + '_price_stakeholders').val()) >= parseInt($('#' + idstart + '_price_public').val())) {
          $('#' + idstart + '_price_stakeholders').val(parseInt($('#' + idstart + '_price_public').val()) - 1)
        }
      }
    } else {
      $('#' + idstart + '_price_stakeholders').val(0)
    }
  }
  $('#points_needed_' + idstart).html(parseInt(base_totaled))

  return parseInt(base_totaled)
}