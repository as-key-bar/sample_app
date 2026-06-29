require "rails_helper"

RSpec.describe "UsersIndex", type: :request do

  fixtures :users
  let(:admin) { users(:michael) }
  let(:non_admin) { users(:archer) }

  it "should display the correct users" do
    log_in_as(admin)
    get users_path
    expect(response).to render_template('users/index')
    expect(response.body).to include('class="pagination"')
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      expect(response.body).to include(user.name)
      unless user == admin
        expect(response.body).to include('data-turbo-method="delete"')
      end
    end
    expect { delete user_path(non_admin) }.to change(User, :count).by(-1)
    expect(response).to redirect_to(users_url)
  end

  it "should not display delete links for non-admin users" do
    log_in_as(non_admin)
    get users_path
    expect(response.body).not_to include('<a data-turbo-method="delete" data-turbo-confirm="You sure?"')
  end
end
