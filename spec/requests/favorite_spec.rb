require 'rails_helper'

RSpec.describe "Favorites", type: :request do

  fixtures :users, :microposts, :favorites
  let(:user) { users(:michael) }

  before do
    log_in_as(user)
  end
  describe "POST /create" do
    it "creates a favorite and redirects back" do
      expect {
        post "/favorites", params: { favorited_id: microposts(:orange).id }
      }.to change(Favorite, :count).by(1)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /destroy" do
    it "destroys the favorite and redirects back" do
      expect {
        delete "/favorites/#{favorites(:three).id}"
      }.to change(Favorite, :count).by(-1)
      expect(response).to redirect_to(root_path)
    end
  end

end
