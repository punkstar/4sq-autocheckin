#!/usr/bin/env ruby

module Autocheckin
  require 'singleton'
  require 'pp'
  
  class Config
    include Singleton
    
    @@configuration = nil
    
    def settings
      if @@configuration.nil?
        configuration_file = File.join(File.dirname(__FILE__), '..', '..', 'etc', 'config.yml')
        @@configuration = YAML.load_file configuration_file
      end
      
      return @@configuration
    end
  end
end