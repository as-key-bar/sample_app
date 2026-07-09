require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  fixtures :users, :relationships

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  describe "POST /block" do
    context "ログインしていない場合" do
      it "ブロックできないか" do
        expect {
          post blocks_path, params: { blocked_id: other_user.id }
        }.not_to change(Block, :count)
        expect(response).to redirect_to(login_path)
      end
    end

    context "ログインしている場合" do
      before do
        log_in_as(user)
      end

      it "ブロックできるか" do
        expect {
          post blocks_path, params: { blocked_id: other_user.id }
        }.to change(Block, :count).by(1)

      end
    end
  end

  describe "DELETE /block/:id" do
    let!(:block) { user.active_blocks.create!(blocked_id: other_user.id) }
    context "ログインしている場合" do
      before do
        log_in_as(user)
      end

      it "ブロック解除できること" do
        expect {
          delete block_path(block)
        }.to change(Block, :count).by(-1)
      end
    end
  end
end