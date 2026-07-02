require 'rails_helper'

RSpec.describe "Mutes", type: :request do
  fixtures :users

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  describe "POST /mutes" do
    before do
      log_in_as(user)
    end

    it "user can mute another user" do
      expect {
        post mutes_path, params: { muted_id: other_user.id }
      }.to change(Mute, :count).by(1)

      expect(response).to redirect_to(other_user)
    end
  end

  describe "DELETE /mutes/:id" do
    let!(:mute) { user.active_mutes.create(muted_id: other_user.id) }

    before do
      log_in_as(user)
    end

    it "user can unmute another user" do
      expect {
        delete mute_path(mute)
      }.to change(Mute, :count).by(-1)

      expect(response).to redirect_to(other_user)
    end
  end
end
