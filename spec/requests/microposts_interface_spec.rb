require "rails_helper"

RSpec.describe "Microposts", type: :request do
  fixtures :users

  let(:user) { users(:michael) }
  let(:user2) { users(:archer) }

  before do
    log_in_as(user)
  end

  it "should paginate microposts" do
    get root_path
    expect(response.body).to include('class="pagination"')
  end

  it "should show errors but not create micropost on invalid submission" do
    
    expect {
        post microposts_path, params: { micropost: { content: "" } }
    }.not_to change(Micropost, :count)
    expect(response.body).to include('error_explanation')
    expect(response.body).to include('/?page=2')  # 正しいページネーションリンク
  end

  it "should create a micropost on valid submission" do
    content = "This micropost really ties the room together"
    expect {
      post microposts_path, params: { micropost: { content: content } }
    }.to change(Micropost, :count).by(1)
    expect(response).to redirect_to root_url

    get root_url(user) 
    expect(response.body).to include(content)
  end

  it "should have micropost delete links on own profile page" do
    get user_path(user)
    expect(response.body).to include('data-turbo-method="delete"')
  end

  it "should be able to delete own micropost" do
    first_micropost = user.microposts.paginate(page: 1).first
    expect {
      delete micropost_path(first_micropost)
    }.to change(Micropost, :count).by(-1)
  end

  it "should not have delete links on other user's profile page" do
    get user_path(user2)
  expected_html = "href=\"#{user2.microposts.first}\" data-turbo-method=\"delete\""
  expect(response.body).not_to include(expected_html)  end
end
