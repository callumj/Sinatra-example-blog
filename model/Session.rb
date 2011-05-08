require 'digest/sha1'

class Session
  include MongoMapper::Document
  
  key :sec1, String
  key :sec2, String
  key :created_at, Time
  
  belongs_to :user
  
  before_save :build
  
  def build
    @created_at = Time.new if @created_at == nil
    @sec1 = Digest::SHA1.hexdigest((@created_at.to_i * rand(1000)).to_s)
    @sec2 = Digest::SHA1.hexdigest((rand(200)).to_s)
    true
  end
  
  def session_valid?
    (Time.now.to_i - @created_at.to_i) < 3600
  end
end