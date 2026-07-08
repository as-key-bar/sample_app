require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  fixtures :users, :relationships

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  describe "POST /mute" do
    context "ログインしていない場合" do
      it "ミュートできないか" do
        expect {
          post mutes_path, params: { muted_id: other_user.id }
        }.not_to change(Mute, :count)
        expect(response).to redirect_to(login_path)
      end
    end


    context "ログインしている場合" do
      before do
        log_in_as(user)
      end

      it "ミュートできるか" do
        expect {
          post mutes_path, params: { muted_id: other_user.id }
        }.to change(Mute, :count).by(1)

      end

      let(:invalid_user_id) { 0 }

      it "存在しないアカウントへのミュート" do
        expect {
          post mutes_path, params: { muted_id: invalid_user_id }        
        }.to change(Mute, :count).by(0)
        expect(response).to have_http_status(:bad_request)
      end

      it "自分自身をミュートできない" do
        expect {
          post mutes_path, params: { muted_id: user.id }
        }.not_to change(Mute, :count)
        expect(response).to have_http_status(:bad_request)
      end

      it "すでにミュートしているユーザーを再度ミュートできない" do
        user.mute(other_user) 
        expect {
          post user_path(other_user)
          post mutes_path, params: { muted_id: other_user.id }
        }.not_to change(Mute, :count)
        expect(response).to redirect_to(user_path(other_user))
      end
    end
  end

  describe "DELETE /mute/:id" do
    let!(:mute) { user.active_mutes.create!(muted_id: other_user.id) }
    context "ログインしていない場合" do
      it "ミュート解除できないか" do
        expect {
          delete mute_path(mute)
        }.not_to change(Mute, :count)
        expect(response).to redirect_to(login_path)
      end
    end

    context "ログインしている場合" do
      before do
        log_in_as(user)
      end

      it "ミュート解除できること" do
        expect {
          delete mute_path(mute)
        }.to change(Mute, :count).by(-1)
      end
    end
  end
end