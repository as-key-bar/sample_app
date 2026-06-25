require "rails_helper"


RSpec.shared_context "ClearMailer" do
  before do
    ActionMailer::Base.deliveries.clear
  end
end 

RSpec.shared_context "PasswordResetForm" do

  let(:user) { users(:michael) }
  let(:reset_user) { controller.instance_variable_get(:@user) }
  before do
    post password_resets_path, params: { password_reset: { email: user.email } }
  end
end


RSpec.describe "PasswordResets", type: :request do
  include_context "ClearMailer"

  it "should show the password reset form" do
    get new_password_reset_path
    expect(response).to render_template('password_resets/new')
    expect(response.body).to include('id="password_reset_email"')
  end

  it "should display an error for invalid email" do
    post password_resets_path, params: { password_reset: { email: "" } }
    expect(response).to render_template('password_resets/new')
    expect(response.body).to include('class="alert alert-danger"')
  end
end

RSpec.describe "PasswordResetForm", type: :request do

  fixtures :users
  include_context "ClearMailer"
  include_context "PasswordResetForm"

  it "should reset with valid email" do
    expect(user.reset_digest).not_to eq(reset_user.reset_digest)
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(flash).not_to be_empty
    expect(response).to redirect_to(root_url)
  end

  it "should display an error for wrong email" do
    get edit_password_reset_path(reset_user.reset_token, email: "")
    expect(response).to redirect_to(root_url)
  end

  it "should display an error for inactive user" do
    reset_user.toggle!(:activated)
    get edit_password_reset_path(reset_user.reset_token,
                                 email: reset_user.email)
    expect(response).to redirect_to(root_url)
  end

  it "should display an error for wrong token" do
    get edit_password_reset_path('wrong token', email: reset_user.email)
    expect(response).to redirect_to(root_url)
  end

  it "should display the password reset form with correct email and token" do
    get edit_password_reset_path(reset_user.reset_token,
                                 email: reset_user.email)
    expect(response).to render_template('password_resets/edit')
    expect(response.body).to include(reset_user.email)
  end
end

RSpec.describe "PasswordForm", type: :request do

  include_context "ClearMailer"
  include_context "PasswordResetForm"

  fixtures :users

  it "should display an error for invalid password and confirmation" do
    patch password_reset_path(reset_user.reset_token),
          params: { email: reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    expect(response).to render_template('password_resets/edit')
    expect(response.body).to include('error_explanation')
  end

  it "should display an error for empty password" do
    patch password_reset_path(reset_user.reset_token),
          params: { email: reset_user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    expect(response).to render_template('password_resets/edit')
    expect(response.body).to include('error_explanation')
  end

  it "should update with valid password and confirmation" do
    patch password_reset_path(reset_user.reset_token),
          params: { email: reset_user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    expect(response).to redirect_to(reset_user)
  end
end
