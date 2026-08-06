require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  fixtures :users, :relationships, :microposts, :notifications, :blocks

  let(:sender_user) { users(:michael) }
  let(:recipient_user) { users(:archer) }

  describe "通知の作成" do
    context "ログインしている場合" do
      before do
        log_in_as(sender_user)
      end

      it "フォロー時に通知が発行されること" do
        expect {
          post relationships_path, params: { followed_id: recipient_user.id }
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.notifiable_type).to eq("Relationship")
        expect(notification.user).to eq(recipient_user)
      end

      it "リプライ時に通知が発行されること" do
        reply_to = microposts(:archer)

        expect {
          post microposts_path, params: { micropost: { content: "reply content", reply_to_id: reply_to.id } }
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.notifiable_type).to eq("Micropost")
        expect(notification.user).to eq(recipient_user)
      end

      it "通常のポスト時に通知が発行されないこと" do
        expect {
          post microposts_path, params: { micropost: { content: "just a normal post" } }
        }.not_to change(Notification, :count)
      end

      it "フォロー解除時に通知が削除されること" do
        post relationships_path, params: { followed_id: recipient_user.id }
        relationship = Relationship.find_by(follower: sender_user, followed: recipient_user)

        expect {
          delete relationship_path(relationship)
        }.to change(Notification, :count).by(-1)
      end

      it "ポスト削除時に通知が削除されること" do
        reply_to = microposts(:archer)
        post microposts_path, params: { micropost: { content: "reply content", reply_to_id: reply_to.id } }
        micropost = sender_user.microposts.find_by(reply_to_id: reply_to.id)

        expect {
          delete micropost_path(micropost)
        }.to change(Notification, :count).by(-1)
      end
    end
  end

  describe "GET /notifications" do
    context "ログインしていない場合" do
      it "ログインページへのリダイレクト" do
        get notifications_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "ログインしている場合" do
      before do
        log_in_as(recipient_user)
      end

      it "通知一覧画面に遷移して通知が表示されること" do
        get notifications_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(microposts(:reply_main).content)
      end

      it "未読通知が既読通知に切り替わること" do
        #jsを絡めた機能なので、patchリクエストで既読フラグが切り替わることだけを確認
        expect {
          patch read_notifications_path
        }.to change { notifications(:reply_one).reload.read }.from(false).to(true)
      end

      it "ヘッダーの通知バッジの数字が、未読通知の数だけ増えること" do
        before_count = recipient_user.notifications.where(read: false).count

        get root_path
        expect(response.body).to include(%(<span class="badge">#{before_count}</span>))

        notifications(:reply_two).update!(read: true)

        get root_path
        expect(response.body).to include(%(<span class="badge">#{before_count - 1}</span>))
      end

      it "ブロックしているユーザーから送られた通知は表示されないこと" do
        log_in_as(users(:blocking))

        get notifications_path
        expect(response.body).not_to include(microposts(:reply_blocked).content)
      end
    end
  end
end