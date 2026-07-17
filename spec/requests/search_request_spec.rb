require 'rails_helper'

RSpec.describe "Searches", type: :request do
  fixtures :microposts

  describe "GET /search" do
    it "検索画面に遷移できること" do
      get search_path
      expect(response).to be_successful
    end
  end

  describe "GET /search?q=query" do
    it "検索結果画面に遷移できること" do
      get search_path + "?q=hoge"
      expect(response).to be_successful
    end

    it "検索対象が想定どおりであること" do
      get search_path + "?q=まさか"
      expect(response).to be_include()
    end
  end
end
