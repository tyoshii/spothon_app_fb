require 'openssl'
# -*- coding: utf-8 -*-

class VotesController < ApplicationController

  before_filter :parse_facebook_cookies  

  def parse_facebook_cookies
    @facebook_cookies ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
  end

  def encrypt( val )
    enc = OpenSSL::Cipher::Cipher.new('aes256')
    enc.encrypt
    enc.pkcs5_keyivgen( 'spothon' )
    (enc.update(val) + enc.final).unpack("H*")[0]
    rescue
      false
  end

  def decrypt( val )
    v = Array.new
    v << val
    dec = OpenSSL::Cipher::Cipher.new('aes256') 
    dec.decrypt 
    dec.pkcs5_keyivgen( 'spothon' )
    dec.update( v.pack("H*")) + dec.final
    rescue  
      false 
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
            'sig'   => encrypt( f1['id'].to_s + Time.current.to_i.to_s ) 
          },
          'left' => {
            'name'  => f2['name'],
            'img'   => 'http://graph.facebook.com/' << f2['id'] << '/picture',
            'sig'   => encrypt( f2['id'].to_s + Time.current.to_i.to_s )
          }
        }

        loop_count -= 1
      end
      
      # question
      @question = Array.new
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
