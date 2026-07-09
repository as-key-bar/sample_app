require "rails_helper"

RSpec.describe UsersController, type: :request do
  fixtures :users

  let(:user) { users(:michael) }
  let(:other_user) { users(:archer) }

  it "should get new" do
    get signup_path
    expect(response).to be_successful
  end

  it "should redirect edit when logged in as wrong user" do
    log_in_as(other_user)
    get edit_user_path(user)
    expect(flash).to be_empty
    expect(response).to redirect_to(root_url)
  end

  it "should redirect update when logged in as wrong user" do
    log_in_as(other_user)
    patch user_path(user), params: { user: { name: user.name,
                                              email: user.email } }
    expect(flash).to be_empty
    expect(response).to redirect_to(root_url)
  end

  it "should redirect index when not logged in" do
    get users_path
    expect(response).to redirect_to(login_url)
  end

    it "should redirect following when not logged in" do
    get following_user_path(user)
    expect(response).to redirect_to(login_url)
  end

  it "should redirect followers when not logged in" do
    get followers_user_path(user)
    expect(response).to redirect_to(login_url)
  end

  it "ミュートしているユーザー一覧ページの表示" do
    log_in_as(user)
    user.mute(other_user)

    get muting_user_path(user)
    expect(response).to be_successful
    expect(user.muting).not_to be_empty
    expect(response.body).to include(user.muting.count.to_s)
    user.muting.each do |u|
      expect(response.body).to include(u.name)
    end
  end
end
