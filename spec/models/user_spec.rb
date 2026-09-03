require "rails_helper"

RSpec.describe User, type: :model do

  fixtures :users, :microposts, :relationships

  let(:user) { users(:michael) }

  it "should be valid" do
    expect(user).to be_valid
  end

  it "name should be present" do
    user.name = "     "
    expect(user).not_to be_valid
  end

  it "email should be present" do
    user.email = "     "
    expect(user).not_to be_valid
  end

  it "name should not be too long" do
    user.name = "a" * 51
    expect(user).not_to be_valid
  end

  it "email should not be too long" do
    user.email = "a" * 244 + "@example.com"
    expect(user).not_to be_valid
  end

  it "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).not_to be_valid
    end
  end

  it "email addresses should be unique" do
    duplicate_user = user.dup
    user.save
    expect(duplicate_user).not_to be_valid
  end
    
  let(:user) do
    User.new(
      name: "Example User",
      email: "user@example.com",
      password: "foobar",
      password_confirmation: "foobar"
    )
  end

  it "password should be present (nonblank)" do
    user.password = user.password_confirmation = " " * 6
    expect(user).not_to be_valid
  end

  it "password should have a minimum length" do
    user.password = user.password_confirmation = "a" * 5
    expect(user).not_to be_valid
  end

  it "authenticated? should return false for a user with nil digest" do
    expect(user.authenticated?(:remember, '')).to be_falsey
  end

  it "associated microposts should be destroyed" do
    user.save
    user.microposts.create!(content: "Lorem ipsum")
    expect { user.destroy }.to change(Micropost, :count).by(-1)
  end

  it "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    expect(michael.following?(archer)).to be_falsey
    michael.follow(archer)
    expect(michael.following?(archer)).to be_truthy
    expect(archer.followers.include?(michael)).to be_truthy
    michael.unfollow(archer)
    expect(michael.following?(archer)).to be_falsey
    # ユーザーは自分自身をフォローできない
    michael.follow(michael)
    expect(michael.following?(michael)).to be_falsey
  end

  it "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # フォローしているユーザーの投稿を確認
    lana.microposts.each do |post_following|
      expect(michael.feed.include?(post_following)).to be_truthy
    end
    # フォロワーがいるユーザー自身の投稿を確認
    michael.microposts.each do |post_self|
      expect(michael.feed.include?(post_self)).to be_truthy
    end
    # フォローしていないユーザーの投稿を確認
    archer.microposts.each do |post_unfollowed|
      expect(michael.feed.include?(post_unfollowed)).to be_falsey
    end    
  end


  it "ミュートしているユーザーのポスト非表示を確認" do
    michael = users(:michael)
    archer  = users(:archer)
    
    michael.follow(archer)
    michael.mute(archer)

    archer.microposts.each do |post_muted|
      expect(michael.feed.include?(post_muted)).to be_falsey
    end    
  end

  it "ブロックしているユーザーのポスト非表示を確認" do
    michael = users(:michael)
    archer  = users(:archer)
    
    michael.follow(archer)
    michael.block(archer)

    archer.microposts.each do |post_muted|
      expect(michael.feed.include?(post_muted)).to be_falsey
    end    
  end

  it "ブロックされているユーザーのポスト非表示を確認" do
    michael = users(:michael)
    archer  = users(:archer)
    
    michael.follow(archer)
    archer.block(michael)

    archer.microposts.each do |post_muted|
      expect(michael.feed.include?(post_muted)).to be_falsey
    end    
  end

  it "ブロック済みのユーザーが自身をフォローしようとした際に、エラーメッセージを表示して弾く" do
    michael = users(:michael)
    archer  = users(:archer)
    
    michael.block(archer)

    expect {
      archer.follow(michael)
    }.not_to change(michael.followers, :count)
  end

  it "ブロック済みのユーザーが自身のプロフィールにアクセスした際に、ポストが表示されないようにする" do
    michael = users(:michael)
    archer  = users(:archer)
    
    michael.block(archer)

    archer.microposts.each do |post_muted|
      expect(michael.feed.include?(post_muted)).to be_falsey
    end    
  end

  it "ブロック済みのユーザーのフォローボタンが無効化される" do
    michael = users(:michael)
    archer  = users(:archer)

    michael.block(archer)

    expect(michael.following?(archer)).to be_falsey
  end

  it "自分がブロックしている相手をフォローしようとした際に、エラーメッセージを表示して弾く" do
    michael = users(:michael)
    archer  = users(:archer)

    michael.block(archer)

    expect {
      michael.follow(archer)
    }.not_to change(michael.following, :count)
  end

  describe "#interaction_blocked_with?" do
    let(:michael) { users(:michael) }
    let(:archer)  { users(:archer) }

    it "ブロック関係がなければfalseを返す" do
      expect(michael.interaction_blocked_with?(archer)).to be_falsey
    end

    it "自分が相手をブロックしていればtrueを返す" do
      michael.block(archer)
      expect(michael.interaction_blocked_with?(archer)).to be_truthy
    end

    it "相手が自分をブロックしていればtrueを返す" do
      archer.block(michael)
      expect(michael.interaction_blocked_with?(archer)).to be_truthy
    end

    it "ミュートしているだけならfalseを返す" do
      michael.mute(archer)
      expect(michael.interaction_blocked_with?(archer)).to be_falsey
    end
  end

  describe "#masks_content_of?" do
    let(:michael) { users(:michael) }
    let(:archer)  { users(:archer) }

    it "ブロック・ミュートの関係がなければfalseを返す" do
      expect(michael.masks_content_of?(archer)).to be_falsey
    end

    it "自分が相手をブロックしていればtrueを返す" do
      michael.block(archer)
      expect(michael.masks_content_of?(archer)).to be_truthy
    end

    it "相手が自分をブロックしていればtrueを返す" do
      archer.block(michael)
      expect(michael.masks_content_of?(archer)).to be_truthy
    end

    it "ミュートしていればtrueを返す" do
      michael.mute(archer)
      expect(michael.masks_content_of?(archer)).to be_truthy
    end
  end

  describe "#favorite" do
    let(:michael) { users(:michael) }
    let(:archer)  { users(:archer) }
    let(:archer_post) { archer.microposts.create!(content: "favorite validation test post") }

    it "ブロック関係がなければいいねできる" do
      expect(michael.favorite(archer_post)).to be_truthy
      expect(michael.favoriting?(archer_post)).to be_truthy
    end

    it "ブロックしている相手の投稿にはいいねできない" do
      michael.block(archer)
      expect(michael.favorite(archer_post)).to be_falsey
      expect(michael.favoriting?(archer_post)).to be_falsey
    end

    it "自分をブロックしている相手の投稿にはいいねできない" do
      archer.block(michael)
      expect(michael.favorite(archer_post)).to be_falsey
      expect(michael.favoriting?(archer_post)).to be_falsey
    end
  end

  context "リポスト機能関連" do
    let(:michael) { users(:michael) }
    let(:archer)  { users(:archer) }
    let(:lana)    { users(:lana) } # michaelはlanaをfixture上で既にフォロー済み

    it "ブロック中ユーザーの投稿のリポストがフィードから除外される" do
      michael.block(archer)
      repost = lana.microposts.create!(reposted_micropost: microposts(:archer), plain_repost: true)

      expect(michael.feed.include?(repost)).to be_falsey
    end

    it "ミュート中ユーザーの投稿のリポストがフィードから除外される" do
      michael.mute(archer)
      repost = lana.microposts.create!(reposted_micropost: microposts(:archer), plain_repost: true)

      expect(michael.feed.include?(repost)).to be_falsey
    end

    it "無関係なリポストは通常通りフィードに表示される" do
      expect(michael.feed.include?(microposts(:plain_repost_sample))).to be_truthy
    end

    it "ブロックしている相手の投稿はリポストできない" do
      michael.block(archer)
      repost = michael.microposts.build(reposted_micropost: microposts(:archer), plain_repost: true)

      expect(repost.save).to be_falsey
    end

    it "自分をブロックしている相手の投稿はリポストできない" do
      archer.block(michael)
      repost = michael.microposts.build(reposted_micropost: microposts(:archer), plain_repost: true)

      expect(repost.save).to be_falsey
    end

    it "plain_reposted?が正しくtrue/falseを返す" do
      original = microposts(:archer)

      expect(michael.plain_reposted?(original)).to be_falsey
      michael.microposts.create!(reposted_micropost: original, plain_repost: true)
      expect(michael.plain_reposted?(original)).to be_truthy
    end
  end

end