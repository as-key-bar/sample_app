# Follow/Mute/Blockのコントローラー(create/destroy)が同一の挙動をすることを検証する。
# 利用側は以下を定義すること:
#   user                          - ログインして操作を行うユーザー
#   other_user                    - 操作対象のユーザー
#   model_class                   - Relationship / Mute / Block
#   create_path                   - createへのパス (例: relationships_path)
#   create_param_key              - createのパラメータキー (例: :followed_id)
#   active_association            - userから辿るhas_many名 (例: :active_relationships)
#   target_fk                     - joinモデルの対象ユーザー外部キー名 (例: :followed_id)
#   member_path                   - ->(record) { relationship_path(record) } の形のlambda
#   trigger_precondition_failure  - ->(user, other_user) { ... } createを失敗させる状態を作るproc
RSpec.shared_examples "unified relationship toggle controller" do
  describe "POST create" do
    context "ログインしていない場合" do
      it "作成されず、ログインページにリダイレクトすること" do
        expect {
          post create_path, params: { create_param_key => other_user.id }
        }.not_to change(model_class, :count)
        expect(response).to redirect_to(login_path)
      end
    end

    context "ログインしている場合" do
      before { log_in_as(user) }

      it "作成できること" do
        expect {
          post create_path, params: { create_param_key => other_user.id }
        }.to change(model_class, :count).by(1)
        expect(response).to redirect_to(other_user)
      end

      it "Turbo Streamリクエストで作成できること" do
        expect {
          post create_path, params: { create_param_key => other_user.id }, as: :turbo_stream
        }.to change(model_class, :count).by(1)
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream].to_s
      end

      context "事前条件が満たされない場合" do
        before { trigger_precondition_failure.call(user, other_user) }

        it "作成できず、flashが設定されリダイレクトされること(HTML)" do
          expect {
            post create_path, params: { create_param_key => other_user.id }
          }.not_to change(model_class, :count)
          expect(flash[:warning]).to be_present
          expect(response).to have_http_status(:found)
        end

        it "作成できないこと(Turbo Stream)" do
          expect {
            post create_path, params: { create_param_key => other_user.id }, as: :turbo_stream
          }.not_to change(model_class, :count)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      it "存在しないユーザーIDの場合は作成できないこと" do
        expect {
          post create_path, params: { create_param_key => 0 }
        }.not_to change(model_class, :count)
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe "DELETE destroy" do
    let!(:record) { user.public_send(active_association).create!(target_fk => other_user.id) }

    context "ログインしていない場合" do
      it "削除されず、ログインページにリダイレクトすること" do
        expect {
          delete member_path.call(record)
        }.not_to change(model_class, :count)
        expect(response).to redirect_to(login_path)
      end
    end

    context "ログインしている場合" do
      before { log_in_as(user) }

      it "標準的なHTMLリクエストで削除できること" do
        expect {
          delete member_path.call(record)
        }.to change(model_class, :count).by(-1)
        expect(response).to redirect_to(other_user)
        expect(response).to have_http_status(:see_other)
      end

      it "Turbo Streamリクエストで削除できること" do
        expect {
          delete member_path.call(record), as: :turbo_stream
        }.to change(model_class, :count).by(-1)
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq Mime[:turbo_stream].to_s
      end

      it "既に削除済みのレコードに対する削除操作はエラーにならないこと" do
        record.destroy
        expect {
          delete member_path.call(record)
        }.not_to change(model_class, :count)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
