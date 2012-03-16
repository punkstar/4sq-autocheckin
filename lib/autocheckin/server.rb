#!/usr/bin/env ruby

module Autocheckin
  require 'sinatra/base'
  require 'foursquare2'
  require 'oauth2'
  require 'pp'
  
  class Server < Sinatra::Base
    
    enable :sessions
    
    set :root, File.join(File.dirname(__FILE__), '..', '..', 'var', 'server')
    
    set :views,         settings.root + '/views'
    set :public_folter, settings.root + '/public'
    
    helpers do
      include Rack::Utils
      alias_method :h, :escape_html
      
      def current_user
        return nil if session[:user].nil?
        return User.first(:id => session[:user])
      end
    end
    
    def initialize
      super()
      
      @settings = Autocheckin::Config.instance.settings
      @foursquare = OAuth2::Client.new(@settings['foursquare']['id'], @settings['foursquare']['secret'], :authorize_url => "/oauth2/authorize", :token_url => "/oauth2/access_token", :site => 'https://foursquare.com')
    end
    
    ########################################################
    # Home page
    ########################################################
    get '/' do
      if session[:user]
        erb :dashboard, :locals => { :devices => current_user.devices }
      else 
        redirect to('/login')
      end
    end
    
    ########################################################
    # Registration
    ########################################################
    post '/register' do
      email    = params[:email]
      password = params[:password]
      
      user = User.new( :email => email, :password => password )
      
      if user.save
        session[:user] = user.id
        redirect to('/?success=true')
      else
        pp user.errors
        
        redirect to('/login?fail=true&email=' + email)
      end
    end
    
    ########################################################
    # Login
    ########################################################
    get '/login' do
      erb :login
    end
    
    post '/login' do
      email    = params[:email]
      password = params[:password]
      
      user = User.first( :email => email )
      
      if not user.nil? and user.authenticate(password)
        session[:user] = user.id
        redirect to('/?success=true')
      else
        redirect to('/login?fail=true&email=' + email)
      end
    end
    
    ########################################################
    # Logout
    ########################################################
    get '/logout' do
      session[:user] = nil
      redirect to('/?success=true')      
    end
    
    ########################################################
    # Add Device
    ########################################################
    post '/device/add' do
      redirect to('/?fail=true') if session[:user].nil?
      
      mac_addr = params[:mac_addr]
      name     = params[:name]
      
      device = Device.new( :user => current_user(), :mac_addr => mac_addr, :name => name )
      
      if device.save
        redirect to('/?success=true')
      else
        redirect to('/?fail=true&mac_addr=' + mac_addr + '&name=' + name)
      end
    end
    
    post '/device/delete' do
      id = params[:id]
      
      device = Device.first( :user => current_user(), :id => id )
      
      if not device.nil?
        device.destroy
        redirect to('/?success=true')
      else
        redirect to('/?fail=true')
      end
    end
    
    ########################################################
    # Send to foursquare for token
    ########################################################
    get '/foursquare/connect' do
      redirect @foursquare.auth_code.authorize_url(:redirect_uri => @settings['foursquare']['callback_url'])
    end
    
    get '/foursquare/callback' do
      code = params[:code]
      token = @foursquare.auth_code.get_token(code, :redirect_uri => @settings['foursquare']['callback_url'])
      
      current_user.update(:token => token.token)
      
      redirect to('/?success=true')
    end
  end
end