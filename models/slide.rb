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
