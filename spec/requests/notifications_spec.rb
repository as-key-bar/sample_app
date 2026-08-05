require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  fixtures :users
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

end
