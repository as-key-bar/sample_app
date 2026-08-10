require 'rails_helper'

RSpec.describe "Favorites", type: :request do

  fixtures :users, :microposts, :favorites
  let(:user) { users(:michael) }

  before do
    log_in_as(user)
  end
  describe "POST /create" do
    it "returns http success" do
      post "/favorites", params: { favorited_id: microposts(:orange).id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      delete "/favorites/#{favorites(:one).id}"
      expect(response).to have_http_status(:success)
    end
  end

end
