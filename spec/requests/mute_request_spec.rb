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
    let!(:mute) { user.active_mutes.create!(muted_id: other_user.id) }
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