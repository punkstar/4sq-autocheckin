#!/usr/bin/env ruby

lib_dir = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift lib_dir if File.directory?(lib_dir)

require 'autocheckin'
require 'autocheckin/server'

# Make sure our schema is up to date
DataMapper.auto_upgrade!

# Start the web server
Autocheckin::Server.run!