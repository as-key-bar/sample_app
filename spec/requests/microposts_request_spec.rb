require "rails_helper"

RSpec.describe MicropostsController, type: :request do

  fixtures :users, :microposts, :blocks

  let(:micropost) { microposts(:orange) }

  it "should redirect create when not logged in" do
    expect {
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    }.not_to change(Micropost, :count)
    expect(response).to redirect_to(login_url)
  end

  it "should redirect destroy when not logged in" do
    expect {
      delete micropost_path(micropost)
    }.not_to change(Micropost, :count)
    expect(response).to redirect_to(login_url)
  end

  it "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:archer)
    expect {
      delete micropost_path(micropost)
    }.not_to change(Micropost, :count)
    expect(response).to redirect_to(root_url)
  end

  context "micropost詳細画面のテスト" do
    
    it "micropost詳細を表示することができるかどうか" do
      log_in_as(users(:michael))
      get micropost_path(microposts(:reply_main))
      expect(response.body).to include("リプライテストのメインポスト")
    end

    it "micropost詳細でリプライを全て表示することができるかどうか" do
      log_in_as(users(:michael))
      get micropost_path(microposts(:reply_main))
      expect(response.body).to include("リプライの子１")    
      expect(response.body).to include("リプライの子２")    
      expect(response.body).to include("リプライの子３")    
    end

    it "micropost詳細でリプライ先ポストを表示することができるかどうか" do
      log_in_as(users(:michael))
      get micropost_path(microposts(:reply_main))
      expect(response.body).to include("リプライの親")
    end

    it "micropost詳細でブロックしているユーザーに自身のポストが表示されないかどうか" do
      log_in_as(users(:blocked))
      get micropost_path(microposts(:reply_blocker)), headers: { "HTTP_REFERER" => root_path }
      expect(response).to redirect_to(root_url)

      follow_redirect!
      expect(flash[:danger]).to eq "You are blocked by this user"
    end

  end
  
  context "micropostリプライのテスト" do
      let(:target_micropost) { microposts(:reply_main) }

    it "micropostのリプライを作成することができるかどうか" do
      log_in_as(users(:michael))
      expect {
        post microposts_path, params: { micropost: { content: "Lorem ipsum", reply_to_id: target_micropost.id } }
      }.to change(Micropost, :count)

      get micropost_path(microposts(:reply_main))
      expect(response.body).to include("Lorem ipsum")

    end
  end

  context "引用リポストのテスト" do
    let(:target_micropost) { microposts(:reply_main) } # archerの投稿

    it "contentとreposted_micropost_idを渡すと、引用リポストとして作成される" do
      log_in_as(users(:michael))
      expect {
        post microposts_path, params: { micropost: { content: "nice post", reposted_micropost_id: target_micropost.id } }
      }.to change(Micropost, :count).by(1)

      repost = users(:michael).microposts.find_by(reposted_micropost_id: target_micropost.id)
      expect(repost.content).to eq("nice post")
      expect(repost.plain_repost).to be false
    end

    it "同じ投稿への引用リポストは複数回作成できる" do
      log_in_as(users(:michael))
      post microposts_path, params: { micropost: { content: "first quote", reposted_micropost_id: target_micropost.id } }

      expect {
        post microposts_path, params: { micropost: { content: "second quote", reposted_micropost_id: target_micropost.id } }
      }.to change(Micropost, :count).by(1)
    end

    it "引用リポストにも通知が発行される" do
      log_in_as(users(:michael))
      expect {
        post microposts_path, params: { micropost: { content: "nice post", reposted_micropost_id: target_micropost.id } }
      }.to change(Notification, :count).by(1)
    end
  end
end
