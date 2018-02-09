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
//= require readmore.min
//= require fittext
//= require jquery.slick
//= require cookies_eu
//= require moment 
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


function calculateCost() {
  var start = moment($('#idea_start_at').val(), 'YYYY-MM-DD HH:mm');
  var endtime = moment($('#idea_end_at').val(), 'YYYY-MM-DD HH:mm');
  base = 0
  if (endtime.isBefore(start)) {

    $('#idea_end_at').val($('#idea_start_at').val());
  } else {
    // get time difference in hour and validate as well
    var duration = moment.duration(endtime.diff(start));
    // figure out how much of each time belongs to the three prices
    for (var m = moment(start); m.isBefore(endtime); m.add(1, 'hours')) {
      if (m.format('HH') <= 7) {
        base += 50;
      } else if (m.format('HH') > 7 && m.format('HH') <= 17) {
        base += 75;
      } else {
        base += 100;
      }
    }

    $('#points_total').html(base);
  }
}

$(function(){ $(document).foundation(); });
