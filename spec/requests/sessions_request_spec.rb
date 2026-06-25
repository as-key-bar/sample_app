require "rails_helper"

RSpec.describe "SessionsController", type: :request do
  it "should get new" do
    get login_path
    expect(response).to be_successful
  end
end
