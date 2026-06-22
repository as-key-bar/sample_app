# メインのサンプルユーザーを1人作成する（再実行可能に）
User.find_or_create_by!(email: "example@railstutorial.org") do |u|
  u.name = "Example User"
  u.password = "foobar"
  u.password_confirmation = "foobar"
  u.admin = true
  u.activated = true
  u.activated_at = Time.zone.now
end

# 追加のユーザーをまとめて生成する
99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.find_or_create_by!(email: email) do |u|
    u.name = name
    u.password = password
    u.password_confirmation = password
    u.activated = true
    u.activated_at = Time.zone.now
  end
end

# ユーザーの一部を対象にマイクロポストを生成する
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end