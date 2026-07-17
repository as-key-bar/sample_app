require 'rails_helper'

RSpec.describe "Searches", type: :request do
  fixtures :microposts

  describe "GET /search" do
    it "検索画面に遷移できること" do
      get search_path
      expect(response).to be_successful
      expect(response.body).to include("enter search query:")
    end
  end

  describe "GET /search?q=query" do
    it "検索結果画面に遷移できること" do
      get search_path + "?q=hoge"
      expect(response).to be_successful
      expect(response.body).to include("検索結果: hoge")
    end

    it "クエリがからの場合、検索結果画面に遷移しないこと" do
      get search_path + "?q="
      expect(response).to be_successful
      expect(response.body).to include("enter search query:")
    end

    it "検索対象が想定どおりであること" do
      get search_path, params: { q: "まさか" }
      expect(response.body).to include("まさかあんなことが起こるとは思わなかった")
      expect(response.body).to include("まさかり担いだ金太郎")
      expect(response.body).not_to include("その「マサカ」が起こった")
      expect(response.body).not_to include("まっさかさまに落ちていった")
      expect(response.body).not_to include("masaka!")
      expect(response.body).not_to include("完全に無関係な文字列")


    end
  end
end
