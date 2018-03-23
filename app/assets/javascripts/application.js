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
//= require jquery.idle.min
//= require points
//= require readmore.min
//= require serviceworker-companion

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

function calculateThing() {
  var deferred = $.Deferred();
  var array_of_functions = []
  var start = moment($('#idea_start_at_date').val() + ' ' + $('#idea_start_at').val(), 'YYYY-MM-DD HH:mm');
  var endtime = moment($('#idea_end_at_date').val() + ' ' + $('#idea_end_at').val(), 'YYYY-MM-DD HH:mm');
  // start date must be in the future

  let now = moment()

  if (start.isBefore(now)) {
    let tomorrow  = moment(new Date()).add(1,'days');

    array_of_functions.push(
        () => { $('#idea_start_at_date').val(now.format('YYYY-MM-DD')); }
    )
  }
  if (endtime.isBefore(start)) {
      array_of_functions.push(
        () => { $('#idea_end_at_date').val($('#idea_start_at_date').val()); }
      )
  }

  // calculate points for this in one function
  let object_size = parseInt($('#idea_thing_size').val())
  let duration = endtime.diff(start, 'days') + 1
  let points_needed = 0
  if (object_size == 1) {
    points_needed = duration * 10
  }
  else if (object_size == 2 ) {
    points_needed = duration * 25
  } else if (object_size == 3) {
    points_needed = duration * 50
  }
  array_of_functions.push(
    () =>  { 
      $('#initial_time_length').html(duration + ' days'+ '<Br />' + points_needed + " points needed")
      $('#points_total').html(parseInt(points_needed))
      $('#idea_points_needed').val(parseInt(points_needed))
  })
  
  setTimeout(function() {
    deferred.resolve(function() {
      array_of_functions.forEach(function(callback) {
        callback();
      });
        
    })
  },200)    
  return deferred.promise()
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
      if ($('#idea_room_needed').val() == "2") {
        base *= 0.6;
      } else if ($('#idea_room_needed').val() == "3") {
        base *= 1.3;
      }

      // discount for allowing others to be there
      if ($('#idea_allow_others').is(":checked") && $('#idea_room_needed').val() != "2") {
        base *= 0.75;
      }

      var duration = moment.duration(endtime.diff(start));

      $('#slotlength_' + eyed).html(endtime.preciseDiff(start) + '<Br />+' + parseInt(base) + " points needed")
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
function checkNested() {

  var idarray = []
  var deferred = $.Deferred();
  var array_of_functions = []
  // see if there are additional form times and calculate them, return an array of points needed
  $('.fields').each(function(index) {
    $(this).find('.subtimes').each(function(ids) { idarray.push($(this).attr('id')) });
  });
  let now = moment()
  let tomorrow  = moment(new Date()).add(1,'days')

  idarray.forEach(function(eyed) {
    // calculatePoints('idea_additionaltimes_attributes_' + eyed)
    var start = moment($('input[name="idea[additionaltimes_attributes][' + eyed + '][start_at_date]"]').val() + ' ' + $('input[name="idea[additionaltimes_attributes][' + eyed + '][start_at]"]').val(), 'YYYY-MM-DD HH:mm');
    var endtime = moment($('input[name="idea[additionaltimes_attributes][' + eyed + '][end_at_date]"]').val() + ' ' + $('input[name="idea[additionaltimes_attributes][' + eyed + '][end_at]"]').val(), 'YYYY-MM-DD HH:mm');
 
    if (start.isBefore(now)) {
       array_of_functions.push(
          () => { $('input[name="idea[additionaltimes_attributes][' + eyed + '][start_at_date]"]').val(tomorrow.format('YYYY-MM-DD')); }
      )
      }
    if (endtime.isBefore(start)) {  
      array_of_functions.push(
        () => { $('input[name="idea[additionaltimes_attributes][' + eyed + '][end_at]"]').val(correctHour($('input[name="idea[additionaltimes_attributes][' + eyed + '][start_at]"]').val().match(/\d\d/)[0]) + ':00'); }
      )
      array_of_functions.push(
        () => { $('input[name="idea[additionaltimes_attributes][' + eyed + '][end_at_date]"]').val($('input[name="idea[additionaltimes_attributes][' + eyed + '][start_at_date]"]').val()); }
      )

         
         
    } 
  })
  setTimeout(function() {
    deferred.resolve(function() {
      array_of_functions.forEach(function(callback) {
        callback();
      });
    })
  },200)
  return deferred.promise()
}

function checkLogic() {
  // main event
  var deferred = $.Deferred();
  var array_of_functions = []
  var start = moment($('#idea_start_at_date').val() + ' ' + $('#idea_start_at').val(), 'YYYY-MM-DD HH:mm');
  var endtime = moment($('#idea_end_at_date').val() + ' ' + $('#idea_end_at').val(), 'YYYY-MM-DD HH:mm');
  // start date must be in the future

  let now = moment()

  if (start.isBefore(now)) {
    let tomorrow  = moment(new Date()).add(1,'days');

    array_of_functions.push(
        () => { $('#idea_start_at_date').val(tomorrow.format('YYYY-MM-DD')); }
    )
  }
  if (endtime.isBefore(start)) {
      array_of_functions.push(
        () => { $('#idea_end_at').val(correctHour($('#idea_start_at').val().match(/\d\d/)[0]) + ':00'); }
      )
      array_of_functions.push(
        () => { $('#idea_end_at_date').val($('#idea_start_at_date').val()); }
      )
  }
  setTimeout(function() {
    deferred.resolve(function() {
      array_of_functions.forEach(function(callback) {
        callback();
      });
        
    })
  },200)    
  return deferred.promise()
}

function correctHour(hour) {
  let h = parseInt(hour)
  if (h < 23) {
    return h + 1
  } else {
    return 0
  }
}

function calculatePrivate() {
  var deferred = $.Deferred();
  var array_of_functions = []
  var start = moment($('#roombooking_start_at_date').val() + ' ' + $('#roombooking_start_at').val(), 'YYYY-MM-DD HH:mm')
  var endtime = moment($('#roombooking_end_at_date').val() + ' ' + $('#roombooking_end_at').val(), 'YYYY-MM-DD HH:mm')


  // get time difference in hour and validate as well
  var duration = endtime.diff(start, 'minutes')
  // console.log('duration is ' + duration)
  if (endtime.isBefore(start)) {
    array_of_functions.push(
      () => {  $('#roombooking_end_at').val(correctHour($('#roombooking_start_at').val().match(/\d\d/)[0]) + ':00');  }
    )
  }
  let rate = parseInt((duration / 60) * 15)
  if (rate <= 0) {
    rate = 15
  }
  $('#points_total').html(rate)
  $('#roombooking_points_needed').val(rate)
  setTimeout(function() {
    deferred.resolve(function() {
      array_of_functions.forEach(function(callback) {
        callback();
      });
        
    })
  },200)    
  return deferred.promise()
}

function calculateCost() {
  var start = moment($('#idea_start_at_date').val() + ' ' + $('#idea_start_at').val(), 'YYYY-MM-DD HH:mm');
  var endtime = moment($('#idea_end_at_date').val() + ' ' + $('#idea_end_at').val(), 'YYYY-MM-DD HH:mm');


  // get time difference in hour and validate as well
  var duration = moment.duration(endtime.diff(start));
  // figure out how much of each time belongs to the three prices
  let base = calcSpan(start, endtime)
  //  get any additional times for new total
    // discount for room needed
  if ($('#idea_room_needed').val() == "2") {
    base_totaled *= 0.6;
  } else if ($('#idea_room_needed').val() == "3") {
    base_totaled *= 1.3;
  }

  // discount for allowing others to be there
  if ($('#idea_allow_others').is(":checked") && $('#idea_room_needed').val() != "2") {
    base_totaled *= 0.75;
  }

  let returned = check_additionals();
  let base_totaled = base + returned.reduce((a, b) => a + b, 0)




  $('#initial_time_length').html(endtime.preciseDiff(start) + '<Br />' + base + " base points needed")
  $('#points_total').html(parseInt(base_totaled))
  $('#idea_points_needed').val(parseInt(base_totaled))
  
  //  check prices are different
  if ($('#idea_price_public').val()) {
    if (parseInt($('#idea_price_public').val()) > 0 ) {
      if ($('#idea_price_stakeholders').val()) {
        if (parseInt($('#idea_price_stakeholders').val()) >= parseInt($('#idea_price_public').val())) {
          $('#idea_price_stakeholders').val(parseInt($('#idea_price_public').val()) - 1)
        }
      }
    } else {
      $('#idea_price_stakeholders').val(0)
    }
  }
}

$(function(){ $(document).foundation(); });
//= require serviceworker-companion
