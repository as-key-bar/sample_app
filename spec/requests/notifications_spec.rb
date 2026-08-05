require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  fixtures :users, :relationships
  let(:user) { users(:michael) }

  describe "GET /index" do
    before do
      log_in_as(user)
    end
    it "returns http success" do
      get "/notifications"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /read" do
    before do
      log_in_as(user)
      Notification.create!(notifiable: relationships(:three), user: user, read: false)
    end

    it "marks the current user's notifications as read" do
      patch read_notifications_path
      expect(response).to have_http_status(:no_content)
      expect(user.notifications.pluck(:read)).to all(be true)
    end
  end

end
