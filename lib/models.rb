# * : 主キー

# User
#   slug: String 文字列 *
#   name: String ユーザーの表示名
#
class User
  include Redis::Objects
  include DataMapper::Resource

  property :slug, String, key: true
  property :name, String

  def initialize(data)
    @slug = data[:slug]
    super
  end

  def self.exists?(slug)
    !first(slug: slug).nil?
  end
end
User.finalize

# Slide
#   slug:       String 文字列 *
#   user_slug:  String ユーザーのスラグ *
#   title:      String スライドの表示名
#
class Slide
  include Redis::Objects
  include DataMapper::Resource

  property :user_slug, String, key: true
  property :slug, String, key: true
  property :title, String
  property :description, String

  def initialize(data)
    @user_slug = data[:user_slug]
    @slug = data[:slug]
    super
  end

  def self.exists?(user_slug, slug)
    !first(user_slug: user_slug, slug: slug).nil?
  end
end
Slide.finalize
