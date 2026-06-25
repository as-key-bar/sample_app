require "rails_helper"

RSpec.describe MicropostsController, type: :request do

  fixtures :users, :microposts

  let(:micropost) { microposts(:orange) }

  it "should redirect create when not logged in" do
    expect {
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    }.not_to change(Micropost, :count)
    expect(response).to redirect_to(login_url)
  end

  it "should redirect destroy when not logged in" do
    expect {
      delete micropost_path(micropost)
    }.not_to change(Micropost, :count)
    expect(response).to redirect_to(login_url)
  end

  it "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:archer)
    expect {
      delete micropost_path(micropost)
    }.not_to change(Micropost, :count)
    expect(response).to redirect_to(root_url)
  end
end
