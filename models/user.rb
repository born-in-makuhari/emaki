# User
class User
  include DataMapper::Resource

  property :id, Serial, key: true
  property :slug, String, unique: true, length: 1..50
  property :name, String, length: 0..50
  property :password, String, length: 1..50
  property :email, String, format: :email_address

  has n, :slide

  def self.exists?(slug)
    return true if first(slug: slug)
    false
  end
end
