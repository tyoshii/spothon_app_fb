function get_left_q () {
  return $("#left-question-num").text().substr(0,1);
}

function get_category () {
  var q_num = get_left_q();
  return $("#q-" + q_num).find("span").attr("class");
}

function decrement_q () {
  var now = get_left_q();
  $("#left-question-num").text( now - 1 + '問' );
}

function next() {
  var id = get_left_q();

  $(".q-word").css("display", "none");
  $(".user").css("display", "none");

  $("#q-"    + id).css("display", "block");
  $(".user-" + id).css("display", "block");
  $(".hidden").attr("style", "display:none");
}
  
function skip_question() {
  decrement_q();
  next();
}

function cancel_post_wall () {
    decrement_q();
    next();
    $(".cover").css("display", "none"); 
    $("#sending").css("display", "none" );
}

function exec_post_wall () {
    decrement_q();
    next();
    $(".cover").css("display", "none"); 
    $("#sending").css("display", "none" );
} 

// onload
$(function() {

  // mouse hover
  var to_light = function() { $(this).css("background-color", "lightcyan") };
  var to_white = function() { $(this).css("background-color", "white")     };

  $(".right").hover( to_light, to_white );
  $(".left").hover( to_light, to_white );

  // click user
  var click_user = function() {
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
    $(".cover").css('display', 'block'); 
    $("#sending").css("display", "block" );

    var message = '';
    $('.q-word').each( function() {
      if ( $(this).css('display') == 'block' ) {
        message += '「' + $(this).find('span').text() + '」';
        message += 'という質問であなたに投票しました！';
      }
    });
    $("#sending").find('textarea').text( message );
  }
  $(".right").click( click_user );
  $(".left").click( click_user );

  // init
  next();
});
 
