require 'sinatra'

get '/' do
  @messages = Message.sort(:create_at.desc).limit(10)
  @messages = [] if @messages == nil
  erb :index
end

get '/create' do
  
  erb :create
end

post '/submit' do
  name = params[:name]
  message = params[:message]
  
  new_message = Message.create({
    :author => name,
    :body => message,
    :created_at => Time.now
  })
  
  new_message.save
  
  redirect to('/')
end
