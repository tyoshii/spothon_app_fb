class WallsController < ApplicationController
  layout "walls"
  before_filter :parse_facebook_cookies  

  def parse_facebook_cookies
    @facebook_cookies ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
  end

  # GET /walls
  def index

      access_token = @facebook_cookies['access_token']
      graph = Koala::Facebook::API.new(access_token)
#graph.put_wall_post(Time.now());
      render :index
  end
  def hoge
    if @facebook_cookies.nil?
      render :index
    else

      access_token = @facebook_cookies['access_token']
      graph = Koala::Facebook::API.new(access_token)

      friends = graph.get_object('me/friends')
      friends_num = friends.size()
      loop_count  = 5

      @target = Array.new
 
      while loop_count > 0
        f1 = friends[ rand(friends_num) ]
        f2 = friends[ rand(friends_num) ]

        @target << {
          'id' => loop_count,
          'right' => {
            'id'    => f1['id'],
            'name'  => f1['name'],
            'img'   => 'http://graph.facebook.com/' << f1['id'] << '/picture',
            'sig'   => encrypt( f1['id'].to_s + Time.current.to_i.to_s ) 
          },
          'left' => {
            'id'    => f2['id'],
            'name'  => f2['name'],
            'img'   => 'http://graph.facebook.com/' << f2['id'] << '/picture',
            'sig'   => encrypt( f2['id'].to_s + Time.current.to_i.to_s )
          }
        }

        loop_count -= 1
      end
      
      # question
      @question = Array.new
      questions = YAML.load_file(Rails.root.join("config/question.yml"))
require "pp"
pp questions
      loop_count = 5
      s_num = questions["sports"].size() 
      q_num = questions["question"].size()
      while loop_count > 0
        s = questions["sports"][ rand(s_num) ]
        q = questions["question"][ rand(q_num) ]
        pp q
        pp s

        @question << {
          "id" => loop_count,
          "category" => s["category"],
          "question" => s["name"] + q, 
        }
        loop_count -= 1
      end  

pp @question
=begin
      @question << { 'id' => 1, 'q' => "野球が好きなのはどっち？"       }
      @question << { 'id' => 2, 'q' => "サッカーが好きなのはどっち？"   }
      @question << { 'id' => 3, 'q' => "ラグビーが好きなのはどっち？"   }
      @question << { 'id' => 4, 'q' => "ゴルフが好きなのはどっち？"     }
      @question << { 'id' => 5, 'q' => "フットサルが好きなのはどっち？" }
=end
      render :votes
    end
  end

end
