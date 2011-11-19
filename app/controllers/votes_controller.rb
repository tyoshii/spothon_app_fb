require 'openssl'

class VotesController < ApplicationController
  layout 'application', :except => [ :ranking, :post_wall_form, :post_wall, :vote ] 

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

  # GET /spothon_vote/ranking
  def ranking
    @ranking = nil 
    case params[:category]
    when "soccer"
      @ranking = Soccer.find_by_fbid( params[:id] )
    when "icehockey"
      @ranking = Icehockey.find_by_fbid( params[:id] )
    when "baseball"
      @ranking = Baseball.find_by_fbid( params[:id] )
    when "basketball"
      @ranking = Basketball.find_by_fbid( params[:id] )
    when "americanfootball"
      @ranking = Americanfootball.find_by_fbid( params[:id] )
    end

    require 'pp'
    pp @ranking

    render :ranking
  end

  # POST /spothon_vote/wall
  def post_wall

    if @facebook_cookies.nil?
      render :post_wall_ng
    else

      access_token = @facebook_cookies['access_token']
      graph = Koala::Facebook::API.new(access_token)
  
      graph.put_wall_post( params[:text] )
  
      render :post_wall_ok
    end
  end

  # GET /spothon_vote/wall
  def post_wall_form
    @message = params[:message]
    render :post_wall_form
  end

  # POST /spothon_vote/vote
  def vote
    p = nil 
    case params[:category]
    when "soccer"
      p = Soccer.find_by_fbid( params[:id] )
    when "icehockey"
      p = Icehockey.find_by_fbid( params[:id] )
    when "baseball"
      p = Baseball.find_by_fbid( params[:id] )
    when "basketball"
      p = Basketball.find_by_fbid( params[:id] )
    when "americanfootball"
      p = Americanfootball.find_by_fbid( params[:id] )
    end

    if p
      p.update_attribute( :point, p.point + 1 )
      render '200'
    else
      case params[:category]
      when "soccer"
        Soccer.new( :fbid => params[:id], :point => 1 ).save
      when "icehockey"
        Icehockey.new( :fbid => params[:id], :point => 1 ).save
      when "baseball"
        Baseball.new( :fbid => params[:id], :point => 1 ).save
      when "basketball"
        Basketball.new( :fbid => params[:id], :point => 1 ).save
      when "americanfootball"
        Americanfootball.new( :fbid => params[:id], :point => 1 ).save
      end
      render '200'
    end

    rescue
      render '500'
  end

  # GET  /spothon_vote
  # POST /spothon_vote
  def index

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

      loop_count = 5
      s_num = questions["sports"].size() 
      q_num = questions["question"].size()
      while loop_count > 0
        s = questions["sports"][ rand(s_num) ]
        q = questions["question"][ rand(q_num) ]

        @question << {
          'id' => loop_count,
          'category' => s['category'],
          'question' => s['name'] + q, 
        }
        loop_count -= 1
      end  

=begin
require "pp"
pp @question

[{"id"=>5, "category"=>"soccer", "question"=>"サッカーをして珍プレーしそうなのは？"},
 {"id"=>4, "category"=>"basketball", "question"=>"バスケを一緒に見に行きたいのは？"},
 {"id"=>3, "category"=>"icehockey", "question"=>"アイスホッケーを愛しているのは？"},
 {"id"=>2, "category"=>"baseball", "question"=>"野球について語り合いたいのは？"},
 {"id"=>1, "category"=>"soccer", "question"=>"サッカーを一緒に見に行きたいのは？"}]
=end
      render :votes
    end
  end

end
