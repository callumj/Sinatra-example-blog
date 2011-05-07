require 'rdiscount'

class Post
  include MongoMapper::Document
  
  key :ref, String
  key :title, String
  key :html, String
  key :markup, String
  key :created_at, Time
  
  belongs_to :user
  
  before_save :fillin_blanks
  
  def fillin_blanks
    markup_obj = RDiscount.new(@markup)
    @html = markup_obj.to_html
    
    @created_at = Time.new if @created_at == nil
    
    @ref = @title.gsub(/\W/, "_").downcase if (@ref == nil || @ref.empty?)
    true
  end
end