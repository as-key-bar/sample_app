require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  fixtures :users, :relationships, :notifications

  let(:sender_user) { users(:michael) }
  let(:recipient_user) { users(:archer) }

  describe "通知の作成" do
    context "ログインしている場合" do
      before do
        log_in_as(sender_user)
      end

      it "フォロー時に通知が発行されること" do
        # expect {
        #   post mutes_path, params: { muted_id: other_user.id }
        # }.to change(Mute, :count).by(1)
      end

      it "リプライ時に通知が発行されること" do
      end

      it "通常のポスト時に通知が発行されないこと" do
      end

      it "フォロー解除時に通知が削除されること" do
      end

      it "ポスト削除時に通知が削除されること" do
      end

    end
  end

  describe "GET /notifications" do
    context "ログインしていない場合" do
      it "ログインページへのリダイレクト" do
      end
    end

    context "ログインしている場合" do
      before do
        log_in_as(recipient_user)
      end

      it "通知一覧画面に遷移して通知が表示されること" do
      end

      it "未読通知が既読通知に切り替わること" do
        #jsを絡めた機能なので、patchリクエストで既読フラグが切り替わることだけを確認
      end

      it "ヘッダーの通知バッジの数字が、未読通知の数だけ増えること" do
      end

      it "ブロックしているユーザーから送られた通知は表示されないこと" do
      end
    end
  end
end