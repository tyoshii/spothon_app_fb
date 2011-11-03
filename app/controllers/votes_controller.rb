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
      graph = Koala::Facebook::API.new(access_token)

      me      = graph.get_object('me')
      friends = graph.get_object('me/friends')
      friends << { 'name' => me['name'], 'id' => me['id'] }

      friends_num = friends.size()
      loop_count  = 5
      
      @target = Array.new
 
      while loop_count > 0
        f1 = friends[ rand(friends_num) ]
        f2 = friends[ rand(friends_num) ]

        @target << {
          'id' => loop_count,
          'right' => {
            'name'  => f1['name'],
            'img'   => 'http://graph.facebook.com/' << f1['id'] << '/picture',
          }
          'left' => {
            'name'  => f2['name'],
            'img'   => 'http://graph.facebook.com/' << f2['id'] << '/picture',
          }
        }

        loop_count -= 1
      end

      render :votes
    end
  end

end
