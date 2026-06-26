require "rails_helper"

RSpec.describe "SiteLayout", type: :request do

  it "should have the correct links" do
    get root_path
    expect(response).to render_template('static_pages/home')
    expect(response.body).to include('href="' + root_path + '"')
    expect(response.body).to include('href="' + help_path + '"')
    expect(response.body).to include('href="' + about_path + '"')
    expect(response.body).to include('href="' + contact_path + '"')
    get contact_path
    expect(response).to render_template('static_pages/contact')
  end
end
