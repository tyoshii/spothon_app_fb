function init () {

  $(".q-word").css("display", "none");
  $(".user").css("display", "none");
  $(".cover").css("display", "none"); 
  $("#sending").css("display", "none" );
  $("div#recommend").css("display", "none");
   
  if ( get_user() )
    get_question();
  else
    return false

  $("#left-question-num").text( '5問' );

  next();
}

function get_question () {
  $.ajax({
    type: "GET",
    url: location.pathname + '/question',
    async: false,
    success: function( data, t ) {
      $("p.q-word").each( function() {
        var d = data.shift();
        $(this).find('img').attr('src', '/assets/icon/' + d['category'] + '.png')
        $(this).find('span').attr('class', d['category']);
        $(this).find('span').text( d['question'] );
      });
    },
    error: function() {
      alert("問題の取得に失敗強いました。リロードして下さい。");
    } 
  });
}

function _append_user( t, key, d ) {
  var root = $(t).find('.' + key );
  root.find('img').attr('src', d[key]['img']);
  root.find('em').text( d[key]['name'] );
  root.find('div.hidden').find('div.sig').text( d[key]['sig'] );
  root.find('div.hidden').find('div.id').text( d[key]['id'] );
}

function get_user () {
  $.ajax({
    type: "GET",
    url: location.pathname + '/user',
    async: false,
    success: function(data, t) {
      $("div.user").each( function() {
        var d = data.shift();
        _append_user( this, 'right', d );
        _append_user( this, 'left',  d );
      });
    },
    error: function() {
      alert("facebookからの友達情報の取得に失敗しました。リロードして下さい。");
      return false;
    } 
  });
}

function get_ranking (category_obj) {
  // loading image
  $(".loading").css("display", "block");

  // select icon
  $("ul.category").each( function() {
    $(this).find('li').attr('class', 'off');
  });

  // get data
  var category = $(category_obj).attr('class');
  var param = { 'category': category };
  $.ajax({
    type: "GET",
    url: location.pathname + '/ranking',
    data: param, 
    async: true,
    success: function(data, t) {
      var ranking = $("ul.ranking");
      ranking.attr('display', 'block');

      // render
      ranking.find('li').each( function() {
        var obj  = $(this);
        var user = data.shift();

        var img = obj.find("span.people").find("img");
        if ( img ) {
          img.attr('src', 'http://graph.facebook.com/' + user[0] + '/picture');
        }          

        var name = obj.find("span.people").find("em");
        if ( name && name.size() ) {
          name.text( user[1]['name'] );
        }
        else {
          obj.find("span.people").text( user[1]['name'] );
        }

        obj.find("span.score").text( user[1]['point'] + '票' );
  
        $(category_obj).parent('li').attr('class', 'on');
        $(".loading").css("display", "none");
      });      
    },
    error: function(r, s, e) {
      alert( 'ランキングデータの取得に失敗しました。' );
      $(".loading").css("display", "none");
    }
  }); 
}

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
    if ( get_left_q() <= 1 ) {
      $("div#recommend").css("display", "block");
      return true;
    }

    decrement_q();
    next();
    $(".cover").css("display", "none"); 
    $("#sending").css("display", "none" );
}

function exec_post_wall () {
    if ( get_left_q() <= 1 ) {
      $("div#recommend").css("display", "block");
      return true;
    }

    var sending = $("#sending");
    var post_data = {    
      'id':   sending.find('div.hidden').find('div.id').text(),
      'sig':  sending.find('div.hidden').find('div.sig').text(),
      'text': sending.find('textarea').text(),
    };

    $.ajax({
      type: "POST",
      url: location.pathname + '/wall',
      data: post_data, 
      async: false,
      complete: function(r, s) {
        alert( 'ウォールに投稿しました。' );
      }
    }); 

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

  // $(".right").hover( to_light, to_white );
  // $(".left").hover( to_light, to_white );

  // click user
  var click_user = function() {
    var user_id = $(this).find(".id").text();
 
    var post_data = {
      "id": user_id, 
      "sig": $(this).find(".sig").text(),
      "category": get_category()
    };
  
    // ajax post id, category, sig
    $.ajax({
      type: "POST",
      url: location.pathname + '/vote',
      data: post_data, 
      async: true,
      complete: function(r, s) {
        // console.log(r);
        // console.log(s);
      }
    }); 

    // get object sending
    var sending = $("#sending");

    // wall post
    $(".cover").css('display', 'block'); 
    sending.css("display", "block" );

    // set wall post data
    var user = $(this).find('em').text();
    sending.find('em').text( user );
    sending.find('img').attr('src', 'http://graph.facebook.com/' + user_id + '/picture' );

    var user_hidden = $(this).find('.hidden');
    sending.find('div.hidden').find('div.sig').text( user_hidden.find('div.sig').text() );
    sending.find('div.hidden').find('div.id').text( user_hidden.find('div.id').text() );
 
    // post wall message
    var message = '';
    $('.q-word').each( function() {
      if ( $(this).css('display') == 'block' ) {
        message += '「' + $(this).find('span').text() + '」';
        message += 'という質問で' + user + 'さんに投票しました！';
      }
    });
    sending.find('textarea').text( message );
  }
  $(".right").click( click_user );
  $(".left").click( click_user );

  // init
  init();
});
 
