enable :sessions

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @session = Session.where(:sec1 => session[:sec1], :sec2 => session[:sec2]).first
    
    if !(@session != nil && @session.session_valid?)
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      if (@auth.provided? && @auth.basic? && @auth.credentials)
        username = @auth.credentials[0]
        password = @auth.credentials[1]
                
        @valid_user = User.where(:user_name => username, :hash_password => Digest::SHA1.hexdigest(password)).first
        if (@valid_user != nil)
          puts "#{@valid_user.display_name} logged on"
          @session = Session.new(:user => @valid_user)
          @session.build
          @session.save
          
          session[:sec1] = @session.sec1
          session[:sec2] = @session.sec2
        end
      end  
    end
    
    return (@session != nil && @session.session_valid?)
  end 
end

before do
  protected! if request.path_info.start_with?("/admin")
end


get '/' do
  redirect to("/index.html")
end

get '/index.:format' do
  response['Cache-Control'] = 'public, max-age=300' if (params["no-cache"] != nil && params["no-cache"].eql?("yes")) #allow Heroku's Varnish cache to be invoked for 5 minutes
  @posts = Post.sort(:created_at.desc).limit(10)
  @posts = [] if @posts == nil
  if (params[:format].eql?("html"))
    erb :index
  elsif (params[:format].eql?("xml") || params[:format].eql?("rss"))
    content = RSS::Maker.make("2.0") do |m|
      m.channel.title = "My messagebook"
      m.channel.link = "http://heroku1.callumj.com"
      m.channel.description = "The latest from my blog"
      m.items.do_sort = true 
      
      @posts.each do |post|
        new_post = m.items.new_item
        new_post.title = post.title
        new_post.description = post.html
        new_post.link = "#{m.channel.link}/##{post.ref}"
        new_post.date = post.created_at
      end
    end
    content.to_s
  end
end

get '/admin' do
  @all_posts = Post.all
  @all_users = User.all
  
  erb :admin
end

#Post management

get '/admin/create' do
  @post = Post.new
  
  erb :create
end

get '/admin/edit/:ref' do  
  @post = Post.where(:ref => params[:ref]).first

  erb :create
end

post '/admin/submit' do
  ref = params[:ref].strip
  title = params[:title].strip_tags
  content = params[:content]
  
  target_post = nil
  
  if ref.empty?
    target_post = Post.new
  else
    target_post = Post.where(:ref => ref).first
  end
    
  target_post.title = title
  target_post.markup = content
  
  target_post.user = @session.user
  
  target_post.save
  
  redirect to('/')
end

#User management

get '/admin/add_user' do
  @user = User.new
  
  erb :user
end

get '/admin/edit_user/:user_name' do
  @user = User.where(:user_name => params[:user_name]).first
  
  erb :user
end

post '/admin/submit_user' do
  prev_user_name = params[:prev_user_name].strip
  user_name = params[:user_name].strip_tags
  display_name = params[:display_name].strip_tags
  password = params[:password].strip
  
  target_user = nil
  
  if prev_user_name.empty?
    target_user = User.new
  else
    target_user = User.where(:user_name => prev_user_name).first
  end
  
  target_user.user_name = user_name
  target_user.display_name = display_name
  
  target_user.password = password if !password.empty?
  
  target_user.save
  
  redirect to('/admin')
end

get '/admin/delete_user/:user_name' do
  if User.count > 1
    @target = User.where(:user_name => params[:user_name]).first
    @target.delete if @target != nil
  end
  
  redirect to('/admin')
end