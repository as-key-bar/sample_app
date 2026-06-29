require "rails_helper"


RSpec.describe "UsersSignupTest", type: :request do

  fixtures :users 

  before do
    ActionMailer::Base.deliveries.clear
  end

  it "invalid signup information" do
    expect {
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    }.not_to change(User, :count)
    expect(response).to have_http_status(:unprocessable_entity)
    expect(response).to render_template('users/new')
    expect(response.body).to include('class="alert alert-danger"')
    expect(response.body).to include('class="field_with_errors"')
  end

  it "valid signup information with account activation" do
    expect {
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    }.to change(User, :count).by(1)
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end
end

RSpec.describe "AccountActivationTest", type: :request do

  fixtures :users

  before do
    ActionMailer::Base.deliveries.clear
    post users_path, params: { user: { name:  "Example User",
                                       email: "user@example.com",
                                       password:              "password",
                                       password_confirmation: "password" } }
    let(:@user) { assigns(:user) }
  end

  it "should not be activated" do
    expect(user.activated?).to be false
  end

  it "should not be able to log in before account activation" do
    log_in_as(user)
    expect(is_logged_in?).to be false
  end

  it "should not be able to log in with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email)
    expect(is_logged_in?).to be false
  end

  it "should not be able to log in with invalid email" do
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    expect(is_logged_in?).to be false
  end

  it "should log in successfully with valid activation token and email" do
    get edit_account_activation_path(user.activation_token, email: user.email)
    expect(user.reload.activated?).to be true
    follow_redirect!
    expect(response).to render_template('users/show')
    expect(is_logged_in?).to be true
  end
end
