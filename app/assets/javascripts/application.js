// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery2
//= require jquery_ujs
//= require foundation
//= require foundation-datetimepicker
//= require jquery-ui/widgets/autocomplete
//= require autocomplete-rails
//= require jquery.mentionable
//= require jquery.scrollTo.min
//= require jquery.timepicker.min
//= require readmore.min
//= require fittext
//= require jquery.slick
//= require cookies_eu
//= require moment 
//= require moment-precise-range
//= require fullcalendar
//= require_tree .

function getContent(id){
  var div_val = $('#ci_' + id).html();
  $('#cit_' + id).html(div_val);
  if(div_val==''){
    return false;
    //empty form will not be submit. You can also alert this message like this. alert(blahblah);
  }
}
function getContentEmptyOK(id){
  var div_val = $('#ci_' + id).html();
  $('#cit_' + id).html(div_val);


}


function check_additionals() {
  var returned = []
  var idarray = []
  // see if there are additional form times and calculate them, return an array of points needed
  $('.fields').each(function(index) {
    $(this).find('.subtimes').each(function(ids) { idarray.push($(this).attr('id')) });
   });
  idarray.forEach(function(eyed) {
    var start = moment($('input[name="idea[additionaltimes_attributes][' + eyed + '][start_at_date]"]').val() + ' ' + $('input[name="idea[additionaltimes_attributes][' + eyed + '][start_at]"]').val(), 'YYYY-MM-DD HH:mm');
    var endtime = moment($('input[name="idea[additionaltimes_attributes][' + eyed + '][end_at_date]"]').val() + ' ' + $('input[name="idea[additionaltimes_attributes][' + eyed + '][end_at]"]').val(), 'YYYY-MM-DD HH:mm');
    if (endtime.isBefore(start)) {
      // TODO fix for split fields
      $('input[name="idea[additionaltimes_attributes][' + eyed + '][end_at_date]"]').val($('input[name="idea[additionaltimes_attributes][' + eyed + '][start_at_date]"]').val());
    } else {
      let base = calcSpan(start, endtime);
      var duration = moment.duration(endtime.diff(start));
      console.log(endtime.preciseDiff(start))
      $('#slotlength_' + eyed).html(endtime.preciseDiff(start) + '<Br />+' + base + " points needed")
      returned.push(base)
    }
  })
  return returned
}

function calcSpan(start, endtime) {
  let base = 0
  for (var m = moment(start); m.isBefore(endtime); m.add(1, 'hours')) {
    if (m.format('HH') <= 7) {
      base += 50;
    } else if (m.format('HH') > 7 && m.format('HH') <= 17) {
      base += 75;
    } else {
      base += 100;
    }
  }
  return base
}

function calculateCost() {
  var start = moment($('#idea_start_at_date').val() + ' ' + $('#idea_start_at').val(), 'YYYY-MM-DD HH:mm');
  var endtime = moment($('#idea_end_at_date').val() + ' ' + $('#idea_end_at').val(), 'YYYY-MM-DD HH:mm');

  if (endtime.isBefore(start)) {
    //  TODO fix for split fields
    $('#idea_end_at').val($('#idea_start_at').val());
  } else {
    // get time difference in hour and validate as well
    var duration = moment.duration(endtime.diff(start));
    // figure out how much of each time belongs to the three prices
    let base = calcSpan(start, endtime)

    // discount for room needed
    if ($('#idea_room_needed').val() == "2") {
      base *= 0.7;
    } else if ($('#idea_room_needed').val() == "3") {
      base *= 1.3;
    }

    // discount for allowing others to be there
    if ($('#idea_allow_others').is(":checked")) {
      base *= 0.75;
    }
    let returned = check_additionals();
    $('#initial_time_length').html(endtime.preciseDiff(start) + '<Br />' + base + " base points needed")
    $('#points_total').html(base + returned.reduce((a, b) => a + b, 0));
  }
}

$(function(){ $(document).foundation(); });
