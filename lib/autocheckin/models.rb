#!/usr/bin/env ruby

module Autocheckin
  require 'foursquare2'
  require 'data_mapper'
  require 'digest/sha1'
  
  # Connect to the database
  DataMapper.setup(:default, Autocheckin::Config.instance.settings['database']['dsn'])
  
  class User
    include DataMapper::Resource
    
    has n, :devices

    property :id,              Serial
    property :email,           String, :required => true, :length => 256, :unique => true
    property :hashed_password, String
    property :salt,            String
    property :token,           String
    
    attr_accessor :password
    
    def generate_hashed_password(password, salt)
      Digest::SHA1.hexdigest(salt + password)
    end
    
    def perform_checkin
      client = Foursquare2::Client.new(:oauth_token => self.token)
      client.add_checkin(:venueId => Autocheckin::Config.instance.settings['foursquare']['venue_id'], :broadcast => 'public', :shout => "Automatic check-in.")
    end
    
    def authenticate(password)
      self.hashed_password == self.generate_hashed_password(password, self.salt)
    end

    
    before :create do
      throw :halt if self.password.nil?
      
      self.salt            = (0...16).map{ ('a'..'z').to_a[rand(26)] }.join
      self.hashed_password = self.generate_hashed_password(self.password, self.salt)
    end
  end
  
  class Device
    include DataMapper::Resource
    
    belongs_to :user
    
    has n, :entries
    
    property :id,       Serial
    property :name,     String, :length => 50, :required => true
    property :mac_addr, String, :required => true, :unique => true
    
    before :save do
      self.mac_addr = self.mac_addr.upcase
    end
  end
  
  class Entry
    include DataMapper::Resource
    
    belongs_to :device
    
    property :id,         Serial
    property :ip_addr,    IPAddress
    property :created_at, DateTime
  end
end