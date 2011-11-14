require 'openssl'

class VotesController < ApplicationController

  before_filter :parse_facebook_cookies  

  def parse_facebook_cookies
    @facebook_cookies ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
  end

  def encrypt( val ) # TODO: to helper
    enc = OpenSSL::Cipher::Cipher.new('aes256')
    enc.encrypt
    enc.pkcs5_keyivgen( 'spothon' )
    (enc.update(val) + enc.final).unpack("H*")[0]
    rescue
      false
  end

  def decrypt( val ) # TODO: to helper
    v = Array.new
    v << val
    dec = OpenSSL::Cipher::Cipher.new('aes256') 
    dec.decrypt 
    dec.pkcs5_keyivgen( 'spothon' )
    dec.update( v.pack("H*")) + dec.final
    rescue  
      false 
  end 

  # POST /votes
  def create

    p = nil 
    case params[:category]
    when "golf"
      p = Golf.find_by_fbid( params[:id] )
    when "baseball"
      p = Baseball.find_by_fbid( params[:id] )
    end

    if p
      p.update_attribute( :point, p.point + 1 )
      render :index
    else
      case params[:category]
      when "golf"
        Golf.new( :fbid => params[:id], :point => 1 ).save
      when "baseball"
        Baseball.new( :fbid => params[:id], :point => 1 ).save
      end
      render :index
    end

    rescue
      render :index
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

#graph.put_wall_post("test");
      
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
