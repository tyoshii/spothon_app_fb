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
      @graph = Koala::Facebook::GraphAPI.new(access_token)
      @profile = @graph.get_object("me")
      @friends = @graph.get_object("me/friends")

      require 'pp'
      pp @friends
      pp @profile


      render :votes
    end
  end

end
