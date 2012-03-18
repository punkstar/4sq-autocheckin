#!/usr/bin/env ruby

module Autocheckin
  require 'sinatra/base'
  require 'foursquare2'
  require 'oauth2'
  require 'sinatra/flash'
  
  class Server < Sinatra::Base
    enable :sessions
    
    register Sinatra::Flash
    
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
      if not session[:user].nil?
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
        
        flash[:success] = "You've been registered"
        redirect to('/')
      else
        flash[:error] = "There was a problem with your registration"
        redirect to('/login?email=' + email)
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
        
        flash[:success] = "You've been logged in"
        redirect to('/')
      else
        flash[:error] = "Invalid username or password"
        redirect to('/login?email=' + email)
      end
    end
    
    ########################################################
    # Logout
    ########################################################
    get '/logout' do
      session[:user] = nil
      flash[:success] = "You have been logged out"
      redirect to('/')
    end
    
    ########################################################
    # Add Device
    ########################################################
    post '/device/add' do
      halt 403, 'You must be logged in' if session[:user].nil?
      
      mac_addr = params[:mac_addr]
      name     = params[:name]
      
      device = Device.new( :user => current_user(), :mac_addr => mac_addr, :name => name )
      
      if device.save
        flash[:success] = "Your device has been added"
        redirect to('/')
      else
        flash[:fail] = "You've been logged in!"
        redirect to('/?mac_addr=' + mac_addr + '&name=' + name)
      end
    end
    
    post '/device/delete' do
      halt 403, 'You must be logged in' if session[:user].nil?
      
      id = params[:id]
      
      device = Device.first( :user => current_user(), :id => id )
      
      if not device.nil?
        device.destroy
        flash[:success] = "Device has been deleted"
        redirect to('/')
      else
        flash[:error] = "There was a problem deleting the device"
        redirect to('/')
      end
    end
    
    ########################################################
    # Send to foursquare for token
    ########################################################
    get '/foursquare/connect' do
      halt 403, 'You must be logged in' if session[:user].nil?
      redirect @foursquare.auth_code.authorize_url(:redirect_uri => @settings['foursquare']['callback_url'])
    end
    
    get '/foursquare/callback' do
      halt 403, 'You must be logged in' if session[:user].nil?
      
      code = params[:code]
      token = @foursquare.auth_code.get_token(code, :redirect_uri => @settings['foursquare']['callback_url'])
      
      current_user.update(:token => token.token)

      flash[:success] = "We're all hooked up for Foursquare!"
      redirect to('/')
    end
  end
end