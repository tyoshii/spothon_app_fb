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

      test_user = open("https://graph.facebook.com/"){|t|
        ActiveSupport::JSON.decode(t.read)
      }
    
      require 'pp'
      pp test_user
    end
  end
end
