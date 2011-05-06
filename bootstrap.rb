require 'mongo_mapper'
require 'sinatra'

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

require 'webapp'