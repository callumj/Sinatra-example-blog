require 'mongo_mapper'
require 'sinatra'
require 'digest/sha1'

#config mongo connectivity
if ENV['MONGOHQ_URL']
  MongoMapper.config = {:RACK_ENV => {'uri' => ENV['MONGOHQ_URL']}}
else
  MongoMapper.config = {:RACK_ENV => {'uri' => 'mongodb://localhost/testdb'}}
end
MongoMapper.connect(:RACK_ENV)

#load up dirs
Dir[File.dirname(__FILE__) + '/model/*.rb'].each do |file| 
  require File.dirname(__FILE__) + "/model/" + File.basename(file, File.extname(file))
end

#create admin user if needed
if (User.all.count == 0)
  new_user = User.new(:user_name => "admin", :display_name => "Admin", :password => "admin")
  new_user.save
end

#overload

class String
	def strip_tags
		self.gsub( %r{</?[^>]+?>}, '' )
	end
end

require "#{File.dirname(__FILE__)}/webapp.rb"