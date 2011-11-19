function get_category () {
  var q_num = $("#left-question-num").text();
  return $("#q-" + q_num).find("span").attr("class");
}

function decrement_q () {
  var q = $("#left-question-num");
  var now = q.text();

  q.text( now - 1 );
}

function next() {
  var q = $("#left-question-num");
  var id = q.text();

  $(".q-word").css("display", "none");
  $(".user").css("display", "none");

  $("#q-"    + id).css("display", "block");
  $("#user-" + id).css("display", "block");
  $(".hidden").attr("style", "display:none");
}
  
function skip_question() {
  decrement_q();
  next();
}

// onload
$(function() {

  // mouse hover
  var to_light = function() { $(this).css("background-color", "lightcyan") };
  var to_white = function() { $(this).css("background-color", "white")     };

  $(".right").hover( to_light, to_white );
  $(".left").hover( to_light, to_white );

  // click user
  var click_func = function() {
    var post_data = {
      "id": $(this).find(".id").text(), 
      "sig": $(this).find(".sig").text(),
      "category": get_category()
    };
  
    // ajax post id, category, sig
    $.ajax({
      type: "POST",
      url: location.href + '/vote',
      data: post_data, 
      async: true,
      complete: function(r, s) {
        console.log(r);
        console.log(s);
      }
    }); 

    // wall post
    var message = '';
    $('.q-word').each( function() {
      if ( $(this).css('display') == 'block' ) {
        message += '「' + $(this).find('span').text() + '」';
        message += 'という質問で'
      }
    });
    message+= $(this).find('.user-name').text();
    message+= ' に投票しました。';

    TINY.box.show({
      iframe: location.href + '/wall?message=' + message,
      width: 500,
      height: 100,
      opacity: 20,
    });

    decrement_q();
    next();
  }
  $(".right").click( click_func );
  $(".left").click( click_func );
 
  // init
  next();
});
 
