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

      let(:invalid_user_id) { 0 }


      it "存在しないアカウントへのブロック" do
        expect {
          post blocks_path, params: { blocked_id: invalid_user_id }        
        }.to change(Block, :count).by(0)
        expect(response).to have_http_status(:bad_request)
      end

      it "自分自身をブロックできない" do
        expect {
          post blocks_path, params: { blocked_id: user.id }
        }.not_to change(Block, :count)
        expect(response).to have_http_status(:bad_request)
      end

      it "不正な文字列をIDとして渡した場合ブロックできない" do
        expect {
          post blocks_path, params: { blocked_id: "invalid" }
        }.not_to change(Block, :count)
        expect(response).to have_http_status(:bad_request)
      end


      it "すでにブロックしているユーザーを再度ブロックできない" do
        user.block(other_user) 
        expect {
          post blocks_path,
              params: { blocked_id: other_user.id },
              headers: { "HTTP_REFERER" => user_path(other_user) }
        }.not_to change(Block, :count)

        expect(response).to redirect_to(user_path(other_user))      
      end      
    end
  end

  describe "DELETE /block/:id" do
    let!(:block) { user.active_blocks.create!(blocked_id: other_user.id) }
    context "ログインしていない場合" do
      it "ブロック解除できないか" do
        expect {
          delete block_path(block)
        }.not_to change(Block, :count)
        expect(response).to redirect_to(login_path)
      end
    end
    
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