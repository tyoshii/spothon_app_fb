class VotesController < ApplicationController

  before_filter :parse_facebook_cookies  

  def parse_facebook_cookies
    @facebook_cookies ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
  end

  # GET /votes
  def index

    if @facebook_cookies.nil?
      render :index
    else

      access_token = @facebook_cookies['access_token']
      graph = Koala::Facebook::GraphAPI.new(access_token)
      @friends = graph.get_object("me/friends")

      render :votes
    end
  end

  # GET /votes/test
  def test

    puts Facebook::APP_ID

    if @facebook_cookies.nil?
      render :index
    else

      url = 'https://graph.facebook.com/'
      url << Facebook::APP_ID
      url << '/accounts/test-users?installed=true&name=HogeFuga&'
      url << 'permissions=publish_stream,email,offline_access,read_stream&'
      url << 'method=post&'
      url << Facebook::SECRET

      test_user = open( url ){|t| 
        ActiveSupport::JSON.decode(t.read) 
      }
      #=>{"id"=>"id", "login_url"=>"url", "access_token" =>"access_token"}      
      


      require 'pp'
      pp test_user
    end
  end
end
