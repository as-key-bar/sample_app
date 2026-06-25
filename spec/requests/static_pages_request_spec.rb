require "rails_helper"

RSpec.describe StaticPagesController, type: :request do

  let(:base_title) { "Ruby on Rails Tutorial Sample App" }

  it "should get home" do
    get root_url
    expect(response).to be_successful
    expect(response).to have_selector "title", text: "Ruby on Rails Tutorial Sample App"
  end

  it "should get help" do
    get help_url
    expect(response).to be_successful
    expect(response).to have_selector("title", text: "Help | #{base_title}")
  end

  it "should get about" do
    get about_url
    expect(response).to be_successful
    expect(response).to have_selector("title", text: "About | #{base_title}")
  end

  it "should get contact" do
    get contact_url
    expect(response).to be_successful
    expect(response).to have_selector("title", text: "Contact | #{base_title}")
  end

  it "should get root" do
    get root_url
    expect(response).to be_successful
  end
end
