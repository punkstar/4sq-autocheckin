#!/usr/bin/env ruby

module Autocheckin
  require 'nmap/parser'
  
  # @FIXME: This is not advised, but fixes the "OpenSSL::SSL::SSLError: SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed" error
  require 'openssl'
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
    
  class Network
    
    def find_hosts()
      parser = Nmap::Parser.parsescan("sudo nmap", "-sP " + Autocheckin::Config.instance.settings['network']['scan_range'])
      
      puts "Nmap args: #{parser.session.scan_args}"
      
      parser.hosts('up') do |host|
          ip  = host.addr
          mac = host.mac_addr

          puts "Found #{ip}"

          if not ip.nil? and not mac.nil?
              yield mac.chomp.upcase, ip.chomp
          end 
      end
    end
  end
end