require "rails_helper"

RSpec.describe MicropostsController, type: :request do

  fixtures :users, :microposts

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
    
    end

    it "micropost詳細でリプライを全て表示することができるかどうか" do
    
    end

    it "micropost詳細でリプライ先ポストを表示することができるかどうか" do
    
    end

    it "micropost詳細でブロックしているユーザーに自身のポストが表示されないかどうか" do
    
    end

  end
  
  context "micropostリプライのテスト" do
    it "micropostのリプライを作成することができるかどうか" do
    
    end
  end



end
