require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  fixtures :users, :relationships

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  describe "POST /mute" do
    context "ログインしている場合" do
      before do
        log_in_as(user)
      end

      it "ミュートできるか" do
        expect {
          post mutes_path, params: { muted_id: other_user.id }
        }.to change(Mute, :count).by(1)

      end
    end
  end

  describe "DELETE /mute/:id" do
    let!(:mute) { user.mute other_user}

    context "ログインしていない場合" do
      it "ミュートの削除ができない" do
        expect {
          delete mutes_path, params: { muted_id: other_user.id }
        }.not_to change(Mute, :count)
      end
    end

    context "ログインしている場合" do
      before do
        log_in_as(user)
      end

      it "ミュート解除できること" do
        expect {
          delete mutes_path, params: { muted_id: other_user.id }
        }.to change(Mute, :count).by(-1)
      end
    end
  end
end