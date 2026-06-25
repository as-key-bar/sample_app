require "rails_helper"

RSpec.describe "Following", type: :request do
  fixtures :users


  let(:user) { users(:michael) }
  let(:other) { users(:archer) }

  before do
    log_in_as(user)
  end

  it "should show the following page" do
    get following_user_path(user)
    expect(response).to be_successful
    expect(user.following).not_to be_empty
    expect(response.body).to include(user.following.count.to_s)
    user.following.each do |u|
      expect(response.body).to include(u.name)
    end
  end

  it "should show the followers page" do
    get followers_user_path(user)
    expect(response).to be_successful
    expect(user.followers).not_to be_empty
    expect(response.body).to include(user.followers.count.to_s)
    user.followers.each do |u|
      expect(response.body).to include(u.name)
    end
  end
end
