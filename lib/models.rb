require 'dm-migrations'

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

# Slide
class Slide
  include DataMapper::Resource

  property :id, Serial, key: true
  property :slug, String, length: 1..50
  property :title, String, length: 0..50
  property :description, String, length: 0..50_000

  belongs_to :user

  def self.exists?(user_slug, slug)
    user = User.first(slug: user_slug)
    return true if first(user: user, slug: slug)
    false
  end
end

DataMapper.finalize
# it doesn't drop any columns.
DataMapper.auto_upgrade!
