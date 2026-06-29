require "rails_helper"

RSpec.describe "UsersProfileTest", type: :request do
  include ApplicationHelper

  fixtures :users
  let(:user) { users(:michael) }

  it "should display the correct profile page" do
    get user_path(user)
    expect(response).to render_template('users/show')
    expect(response.body).to include(full_title(user.name))
    expect(response.body).to include(user.name)
    expect(response.body).to include('class="gravatar"')
    expect(response.body).to include(user.microposts.count.to_s)
    expect(response.body).to include('class="pagination"')
    user.microposts.paginate(page: 1).each do |micropost|
      expect(response.body).to include(micropost.content)
    end
  end
end
