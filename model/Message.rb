class Message
  include MongoMapper::Document

  key :author, String
  key :body,  String
  key :created_at, Time
end