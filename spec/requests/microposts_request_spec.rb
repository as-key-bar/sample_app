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

  context "リプライ一覧のブロック・ミュートフィルタ" do
    let(:viewer) { users(:michael) }
    let(:author) { users(:archer) }
    let(:target_content) { "reply visibility test content" }
    let!(:root_post) { viewer.microposts.create!(content: "root post for reply visibility test") }
    let!(:reply) { author.microposts.create!(content: target_content, reply_to: root_post) }

    before { log_in_as(viewer) }

    def perform_request
      get micropost_path(root_post)
    end

    it_behaves_like "hides content from blocked and muted authors"
  end

  context "ブロック・ミュート中の投稿内容のマスキング" do
    let(:viewer) { users(:michael) }
    let(:author) { users(:archer) }
    let(:masked_message) { "This post is hidden." }

    before { log_in_as(viewer) }

    context "詳細画面のメイン投稿" do
      let!(:target_post) { author.microposts.create!(content: "masking test main post") }

      it "通常時は本文が表示されること(前提条件)" do
        get micropost_path(target_post)
        expect(response.body).to include("masking test main post")
        expect(response.body).not_to include(masked_message)
      end

      it "ブロックしている相手の投稿は本文が隠れること" do
        viewer.block(author)
        get micropost_path(target_post)
        expect(response.body).not_to include("masking test main post")
        expect(response.body).to include(masked_message)
      end

      it "ミュートしている相手の投稿は本文が隠れること" do
        viewer.mute(author)
        get micropost_path(target_post)
        expect(response.body).not_to include("masking test main post")
        expect(response.body).to include(masked_message)
      end
    end

    context "リプライ先投稿" do
      let!(:parent_post) { author.microposts.create!(content: "masking test parent post") }
      let!(:child_post) { viewer.microposts.create!(content: "masking test child post", reply_to: parent_post) }

      it "ブロックしている相手のリプライ先投稿は本文が隠れること" do
        viewer.block(author)
        get micropost_path(child_post)
        expect(response.body).not_to include("masking test parent post")
        expect(response.body).to include(masked_message)
      end
    end

    context "引用リポストの引用元投稿" do
      let!(:original_post) { author.microposts.create!(content: "masking test original post") }
      let!(:quote_post) { viewer.microposts.create!(content: "masking test quote post", reposted_micropost: original_post, plain_repost: false) }

      it "ブロックしている相手の引用元投稿は本文が隠れること" do
        viewer.block(author)
        get micropost_path(quote_post)
        expect(response.body).to include("masking test quote post")
        expect(response.body).not_to include("masking test original post")
        expect(response.body).to include(masked_message)
      end
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
