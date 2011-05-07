require 'digest/sha1'

class User
  include MongoMapper::Document
  
  key :user_name, String
  key :display_name, String
  key :hash_password, String
  key :last_logon, Time
  
  has_many :posts
  has_many :sessions
  
  def password=(pwd)
    @hash_password = Digest::SHA1.hexdigest(pwd)
    @hash_password
  end
  
  def password(pwd)
    password = pwd
  end
end