require "rails_helper"

RSpec.describe SessionsHelper, type: :helper do
  fixtures :users 

  let(:user) { users(:michael) }

  before do
    remember(user)
  end

  it "current_user returns right user when session is nil" do
    expect(user).to eq(current_user)
    expect(is_logged_in?).to be true
  end

  it "current_user returns nil when remember digest is wrong" do
    user.update_attribute(:remember_digest, User.digest(User.new_token))
    expect(current_user).to be_nil
  end
end
