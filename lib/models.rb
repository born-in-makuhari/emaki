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
end

# Slide
class Slide
  include DataMapper::Resource

  property :id, Serial, key: true
  property :slug, String, length: 1..50
  property :title, String, length: 0..50
  property :description, String, length: 0..50_000

  belongs_to :user
end

DataMapper.finalize
# it doesn't drop any columns.
DataMapper.auto_upgrade!

user = User.create(
  slug: :user_sample,
  name: 'ユーザ',
  password: 'password',
  email: 'kazu11518@gmail.com'
)

user.save

slide = Slide.create(
  user: user,
  slug: :sample,
  title: "これがタイトル",
  description: "これが説明"
)

slide.save
