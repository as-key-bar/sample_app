require 'rails_helper'

RSpec.describe "Favorites", type: :request do

  fixtures :users, :microposts, :favorites
  let(:user) { users(:michael) }

  context "未ログイン時" do
    describe "POST /create" do
      it "いいねが作成されず、root_pathにリダイレクト" do
        expect {
          post "/favorites", params: { favorited_id: microposts(:orange).id }
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    describe "DELETE /destroy" do
      it "いいねが削除されず、root_pathにリダイレクト" do
        expect {
          delete "/favorites/#{favorites(:three).id}"
        }.not_to change(Favorite, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context "ログイン時" do
    before do
      log_in_as(user)
    end
    describe "POST /create" do
      it "いいねが作成され、root_pathにリダイレクト" do
        expect {
          post "/favorites", params: { favorited_id: microposts(:orange).id }
        }.to change(Favorite, :count).by(1)
        expect(response).to redirect_to(root_path)
      end

      it "いいねが作成され、元々居たURLにリダイレクト" do
        referer = micropost_path(microposts(:cat_video))

        expect {
          post "/favorites", params: { favorited_id: microposts(:orange).id },
                              headers: { "HTTP_REFERER" => referer }
        }.to change(Favorite, :count).by(1)
        expect(response).to redirect_to(referer)
      end


    end

    describe "DELETE /destroy" do
      it "いいねが削除され、root_pathにリダイレクト" do
        expect {
          delete "/favorites/#{favorites(:three).id}"
        }.to change(Favorite, :count).by(-1)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
