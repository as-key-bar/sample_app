require "rails_helper"

RSpec.describe "InvalidPasswordTest", type: :request do

  fixtures :users
  let(:user) { users(:michael) }

  it "should display the correct login path" do
    get login_path
    expect(response).to render_template('sessions/new')
  end

  it "should show an error for valid email/invalid password" do
    post login_path, params: { session: { email:    user.email,
                                          password: "invalid" } }
    expect(is_logged_in?).to be false
    expect(response).to render_template('sessions/new')
    expect(flash).not_to be_empty
    get root_path
    expect(flash).to be_empty
  end
end


RSpec.describe "ValidLoginTest", type: :request do
  fixtures :users
  let(:user) { users(:michael) }

  before do
    post login_path, params: { session: { email:    user.email,
                                        password: 'password' } }
  end
  it "valid login" do
    expect(is_logged_in?).to be true
    expect(response).to redirect_to(user_path(user))
  end

  it "redirect after login" do
    expect(response).to redirect_to(user_path(user))
    get user_path(user)
    expect(response).to render_template('users/show')
    expect(response.body).not_to include("href=\"#{login_path}\"")
    expect(response.body).to include("href=\"#{logout_path}\"")
    expect(response.body).to include("href=\"#{user_path(user)}\"")
  end
end


RSpec.describe "LogoutTest", type: :request do
  fixtures :users
  let(:user) { users(:michael) }

  before do
    post login_path, params: { session: { email:    user.email,
                                        password: 'password' } }
    delete logout_path
  end

  it "successful logout" do
    expect(is_logged_in?).to be false
    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(root_url)
  end

  it "redirect after logout" do
    expect(response).to redirect_to(root_url)
    get root_url
    expect(response.body).to include("href=\"#{login_path}\"")
    expect(response.body).not_to include("href=\"#{logout_path}\"")
    expect(response.body).not_to include("href=\"#{user_path(user)}\"")
  end

  it "should still work after logout in second window" do
    delete logout_path
    expect(response).to have_http_status(:see_other)
    expect(response).to redirect_to(root_url)
  end
end

RSpec.describe "RememberMeTest", type: :request do
  fixtures :users
  let(:user) { users(:michael) }

  it "login with remembering" do
    log_in_as(user, remember_me: '1')
    expect(cookies[:remember_token]).not_to be_blank
  end

  it "login without remembering" do
    # Cookieを保存してログイン
    log_in_as(user, remember_me: '1')
    # Cookieが削除されていることを検証してからログイン
    log_in_as(user, remember_me: '0')
    expect(cookies[:remember_token]).to be_blank
  end
end