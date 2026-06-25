require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  fixtures :users, :relationships

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  describe "POST /relationships" do
    context "ログインしていない場合" do
      it "関係性は作成されず、ログインページにリダイレクトすること" do
        expect {
          post relationships_path, params: { followed_id: other_user.id }
        }.not_to change(Relationship, :count)
        
        expect(response).to redirect_to(login_path) # もし別名なら適切なパスに変更してください
      end
    end

    context "ログインしている場合" do
      before do
        log_in_as(user) # ログイン状態を作るヘルパーメソッド（※補足参照）
      end

      it "標準的なHTMLリクエストでユーザーをフォローできること" do
        expect {
          post relationships_path, params: { followed_id: other_user.id }
        }.to change(Relationship, :count).by(1)
        
        expect(response).to redirect_to(other_user)
      end

      it "Turbo Streamリクエストでユーザーをフォローできること" do
        expect {
          post relationships_path, params: { followed_id: other_user.id }, as: :turbo_stream
        }.to change(Relationship, :count).by(1)
        
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream].to_s
      end
    end
  end

  describe "DELETE /relationship/:id" do
    let!(:relationship) { user.active_relationships.create(followed_id: other_user.id) }

    context "ログインしていない場合" do
      it "関係性は削除されず、ログインページにリダイレクトすること" do
        expect {
          delete relationship_path(relationship)
        }.not_to change(Relationship, :count)
        
        expect(response).to redirect_to(login_path)
      end
    end

    context "ログインしている場合" do
      before do
        log_in_as(user)
      end

      it "標準的なHTMLリクエストでフォロー解除できること" do
        expect {
          delete relationship_path(relationship)
        }.to change(Relationship, :count).by(-1)
        
        expect(response).to redirect_to(other_user)
        expect(response).to have_http_status(:see_other) # status: :see_other の検証
      end

      it "Turbo Streamリクエストでフォロー解除できること" do
        expect {
          delete relationship_path(relationship), as: :turbo_stream
        }.to change(Relationship, :count).by(-1)
        
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream].to_s
      end
    end
  end
end