
$(function() {

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
    $(".sig").attr("style", "display:none");
  }


  // mouse hover
  var to_light = function() { $(this).css("background-color", "lightcyan") };
  var to_white = function() { $(this).css("background-color", "white")     };

  $(".right").hover( to_light, to_white );
  $(".left").hover( to_light, to_white );

  // click user
  $(".right").click(
    function() {
      var sig = $(this).find(".sig").text();

      // ajax post sig

      decrement_q();
      next();
    }
  );
  
  // init
  next();
});
