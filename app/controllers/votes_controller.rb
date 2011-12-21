require 'openssl'

class VotesController < ApplicationController
  layout 'application', :except => [ :redirect, :ranking, :user, :post_wall, :vote ] 
  
  before_filter :set_locale
  before_filter :parse_facebook_cookies, :except => [ :vote, :question ] 

  def set_locale
    @locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first 
    I18n.locale = @locale
  end

  def parse_facebook_cookies
    @auth = Koala::Facebook::OAuth.new(
      Facebook::APP_ID,
      Facebook::SECRET,
      Facebook::REDIRECT_URL,
    )

    #@facebook_cookies = @auth.get_user_info_from_cookie(cookies)
    #if @facebook_cookies.nil?
  
      if ( params[:code] )
        @facebook_cookies = Hash.new
        @access_token = @auth.get_access_token( params[:code] )
      else
        redirect_to @auth.url_for_oauth_code({
          :callback => Facebook::REDIRECT_URL,
          :permissions => "publish_stream"
        })
      end
    #else
      #@access_token = @facebook_cookies['access_token']
    #end
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
      graph = Koala::Facebook::API.new( @access_token )

      ranking = Hash.new
      ids     = Array.new
      graph.get_object('me/friends').each{|f|
        ranking[f['id']] = f['name']
        ids.push( f['id'] )
      }
  
      score = Vote.select( 'fbid, ' + params[:category] + ' AS point' ).where( :fbid => ids ).order( params[:category] + " desc" ).limit(5)
  
      result = Array.new
      score.each{|s|
        result.push( :id => s.fbid, :name => ranking[s.fbid], :point => s.point )
      }

      render :json => result
  end

  # POST /spothon_vote/wall
  def post_wall
      desc = I18n.t ".votes.index.post_desc"; 
      graph = Koala::Facebook::API.new( @access_token )
      graph.put_wall_post( params[:text], {
        :name => 'spothon vote',
        :link => "http://www.facebook.com/spothon?sk=app_127567974001631",
        #:link => "http://spothon-vote.heroku.com/spothon_vote",
        :caption => 'Facebook App',
        :description => desc,
        :picture => "http://s3.amazonaws.com/spothon/images/facebook/share_icon.jpg",
      }, params[:id] )
      render :post_wall_ok
  end

  # POST /spothon_vote/vote
  def vote
    v = Vote.select( 'id, ' + params[:category] + ' AS point' ).find_by_fbid!( params[:id] ) 
    Vote.update( v.id, params[:category] =>  v.point + 1 )
    render '200'

    rescue => err
      Vote.new( :fbid => params[:id], params['category'] => 1 ).save

    render '200'
  end

  # GET /spothon_vote/question
  def question
    @question = Array.new

    yml = 'config/question_' + @locale + '.yml'
    questions = YAML.load_file(Rails.root.join( yml ))

    loop_count = 5
    s_num = questions["sports"].size() 
    q_num = questions["question"].size()
    while loop_count > 0
      s = questions["sports"][ rand(s_num) ]
      q = questions["question"][ rand(q_num) ]

      @question << {
        'id' => loop_count,
        'category' => s['category'],
        'question' => sprintf( q, s['name'] ), 
      }
      loop_count -= 1
    end  

    render :json => @question
  end

  # GET /spothon_vote/user
  def user
      graph = Koala::Facebook::API.new( @access_token )

      friends = graph.get_object('me/friends')
      friends_num = friends.size()

      if friends_num < 10
        return head(:bad_request)
        #return render :no_friends
      end

      loop_count  = 5
      @target = Array.new
 
      while loop_count > 0
        f1 = friends[ rand(friends_num) ]
        f2 = friends[ rand(friends_num) ]

        if f1['id'] == f2['id']
          next
        end

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

    render :json => @target
  end  


  # GET  /spothon_vote
  # POST /spothon_vote
  def index
    case params[:job]
    when 'user' then
      user
    when 'post' then
      post_wall
    when 'ranking' then
      ranking
    else 
      render :index
    end
  end

end
