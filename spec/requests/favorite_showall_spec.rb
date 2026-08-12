require 'rails_helper'

RSpec.describe "Favorites Show", type: :request do
  fixtures :users, :microposts, :favorites

  let(:user1) { users(:michael) }
  let(:user2) { users(:archer) }
  let(:micropost) { microposts(:archer) }
  let(:favorite) { favorites(:one) }

  describe "GET users/:id/favorites" do
    context "未ログイン時" do
      it "リダイレクトされること" do
        get user_favorites_path(user1)
        expect(response).to redirect_to(login_path)
      end
    end

    context "ログイン時" do
      before do
        log_in_as(user1)
      end

      it "200 OKが返ること" do
        get user_favorites_path(user1)
        expect(response).to have_http_status(:ok)
      end

      it "ユーザーのいいね一覧が表示されること" do
        get user_favorites_path(user1)
        expect(response.body).to include(micropost.content)
      end
    end
  end
end