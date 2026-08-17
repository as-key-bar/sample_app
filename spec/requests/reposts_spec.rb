require 'rails_helper'

RSpec.describe "Reposts", type: :request do
  fixtures :users, :microposts

  let(:user) { users(:michael) }
  let(:original) { microposts(:archer) }

  context "未ログイン時" do
    describe "POST /create" do
      it "リポストが作成されず、root_pathにリダイレクト" do
        expect {
          post "/reposts", params: { reposted_micropost_id: original.id }
        }.not_to change(Micropost, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    describe "DELETE /destroy" do
      it "リポストが削除されず、root_pathにリダイレクト" do
        expect {
          delete "/reposts/#{original.id}"
        }.not_to change(Micropost, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context "ログイン時" do
    before do
      log_in_as(user)
    end

    describe "POST /create" do
      it "プレーンリポストが作成され、元のURLにリダイレクト" do
        referer = micropost_path(original)

        expect {
          post "/reposts", params: { reposted_micropost_id: original.id },
                            headers: { "HTTP_REFERER" => referer }
        }.to change(Micropost, :count).by(1)
        expect(response).to redirect_to(referer)
      end

      it "重複作成しようとすると失敗し、エラーメッセージが表示される" do
        log_in_as(users(:lana))

        expect {
          post "/reposts", params: { reposted_micropost_id: microposts(:orange).id }
        }.not_to change(Micropost, :count)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end
    end

    describe "DELETE /destroy" do
      it "自分のリポストを削除できる" do
        log_in_as(users(:lana))
        repost = microposts(:plain_repost_sample)

        expect {
          delete "/reposts/#{repost.id}"
        }.to change(Micropost, :count).by(-1)
        expect(response).to redirect_to(root_path)
      end

      it "他人のリポストは削除できない" do
        repost = microposts(:plain_repost_sample) # lanaのリポスト、ログイン中はmichael

        expect {
          delete "/reposts/#{repost.id}"
        }.not_to change(Micropost, :count)
      end
    end
  end
end
