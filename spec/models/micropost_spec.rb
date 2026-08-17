require "rails_helper"

RSpec.describe Micropost, type: :model do
  # フィクスチャのusersを読み込む
  fixtures :users, :microposts

  # letを使って定義
  let(:user) { users(:michael) }
  let(:micropost) { user.microposts.build(content: "Lorem ipsum") }

  it "should be valid" do
    expect(micropost).to be_valid
  end

  it "user id should be present" do
    micropost.user_id = nil
    expect(micropost).not_to be_valid
  end
  
  it "content should be present" do
    micropost.content = "   "
    expect(micropost).not_to be_valid 
  end

  it "content should be at most 140 characters" do
    micropost.content = "a" * 141
    expect(micropost).not_to be_valid
  end

  it "order should be most recent first" do
    expect(microposts(:most_recent)).to eq(Micropost.first)
  end

  context "リポスト機能関連" do
    fixtures :notifications

    let(:original) { microposts(:archer) } # archerの投稿（userはmichaelなので他人の投稿）

    it "プレーンリポストの作成" do
      repost = user.microposts.build(reposted_micropost: original, plain_repost: true)
      expect(repost).to be_valid
    end

    it "引用リポストの作成ができる" do
      quote = user.microposts.build(reposted_micropost: original, plain_repost: false, content: "nice post")
      expect(quote).to be_valid
    end

    it "引用リポストの作成の際にcontentが必須である" do
      quote = user.microposts.build(reposted_micropost: original, plain_repost: false, content: nil)
      expect(quote).not_to be_valid
    end

    it "プレーンリポストに対してユニーク制約" do
      user.microposts.create!(reposted_micropost: original, plain_repost: true)
      duplicate = user.microposts.build(reposted_micropost: original, plain_repost: true)
      expect(duplicate).not_to be_valid
    end

    it "引用リポストに対してユニーク制約がない" do
      user.microposts.create!(reposted_micropost: original, plain_repost: false, content: "first quote")
      second_quote = user.microposts.build(reposted_micropost: original, plain_repost: false, content: "second quote")
      expect(second_quote).to be_valid
    end

    it "元投稿をdestroyすると、紐づくリポストも一緒に消える" do
      repost = user.microposts.create!(reposted_micropost: original, plain_repost: true)

      expect {
        original.destroy
      }.to change(Micropost, :count).by(-2)
      expect(Micropost.exists?(repost.id)).to be false
    end

    it "自分の投稿への自己リポストは通知されない／他人の投稿へのリポストは元投稿者に通知される" do
      own_post = microposts(:orange) 

      expect {
        user.microposts.create!(reposted_micropost: own_post, plain_repost: true)
      }.not_to change(Notification, :count)

      expect {
        user.microposts.create!(reposted_micropost: original, plain_repost: true)
      }.to change(Notification, :count).by(1)
      expect(Notification.last.user).to eq(users(:archer))
    end
  end
end
