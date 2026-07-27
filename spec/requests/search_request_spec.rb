require 'rails_helper'

RSpec.describe "Searches", type: :request do
  fixtures :users, :microposts

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
      log_in_as(users(:michael))

      expect {
        post microposts_path, params: { micropost: { content: "まさかあんなことが起こるとは思わなかった" } }
        post microposts_path, params: { micropost: { content: "まさかり担いだ金太郎" } }
        post microposts_path, params: { micropost: { content: "その「マサカ」が起こった" } }
        post microposts_path, params: { micropost: { content: "まっさかさまに落ちていった" } }
        post microposts_path, params: { micropost: { content: "masaka!" } }
        post microposts_path, params: { micropost: { content: "完全に無関係な文字列" } }
      }.to change(Micropost, :count)
      

      get search_path, params: { q: "まさか" }
      expect(response.body).to include("まさかあんなことが起こるとは思わなかった")
      expect(response.body).to include("まさかり担いだ金太郎")
      expect(response.body).to include("その「マサカ」が起こった")
      expect(response.body).not_to include("まっさかさまに落ちていった")
      expect(response.body).not_to include("masaka!")
      expect(response.body).not_to include("完全に無関係な文字列")
    end

    context "ファジーな検索" do
      it "検索対象はひらがな・全角カタカナ混じり文章：今回はテストです" do
        log_in_as(users(:michael))

        expect {
          post microposts_path, params: { micropost: { content: "今回はテストです" } }
        }.to change(Micropost, :count)
        
        get search_path, params: { q: "こんかいはてすと" }
        expect(response.body).to include("今回はテストです")

        get search_path, params: { q: "コンカイハテスト" }
        expect(response.body).to include("今回はテストです")

        get search_path, params: { q: "今回はテスト" }
        expect(response.body).to include("今回はテストです")
      end

      it "検索対象はひらがな・半角カタカナ混じり文章：今回はﾃｽﾄです" do
        log_in_as(users(:michael))

        expect {
          post microposts_path, params: { micropost: { content: "今回はﾃｽﾄです" } }
        }.to change(Micropost, :count)
        
        get search_path, params: { q: "こんかいはてすと" }
        expect(response.body).to include("今回はﾃｽﾄです")

        get search_path, params: { q: "ｺﾝｶｲハテスト" }
        expect(response.body).to include("今回はﾃｽﾄです")

        get search_path, params: { q: "今回はテスト" }
        expect(response.body).to include("今回はﾃｽﾄです")
      end

      it "検索対象はひらがな・漢字混じり文章：今から提示する文章はテストなんです" do
        log_in_as(users(:michael))

        expect {
          post microposts_path, params: { micropost: { content: "今から提示する文章はテストなんです" } }
        }.to change(Micropost, :count)
        
        get search_path, params: { q: "いまから" }
        expect(response.body).to include("今から提示する文章はテストなんです")

        get search_path, params: { q: "イマカラ" }
        expect(response.body).to include("今から提示する文章はテストなんです")

        get search_path, params: { q: "居間から" }
        expect(response.body).to include("今から提示する文章はテストなんです")
      end

      it "検索対象はひらがな・数字混じり文章：テストに12件もテストを行います。十二件も、１２件もですよ" do
        log_in_as(users(:michael))

        expect {
          post microposts_path, params: { micropost: { content: "テストに12件もテストを行います。十二件も、１２件もですよ" } }
        }.to change(Micropost, :count)
        
        get search_path, params: { q: "じゅうにけん" }
        expect(response.body).to include("テストに12件もテストを行います。十二件も、１２件もですよ")

        get search_path, params: { q: "ジュウニケンモ" }
        expect(response.body).to include("テストに12件もテストを行います。十二件も、１２件もですよ")

        get search_path, params: { q: "十二件" }
        expect(response.body).to include("テストに12件もテストを行います。十二件も、１２件もですよ")
      end
    end

    context "AND検索のテスト" do
      it "半角スペースの接続" do
        log_in_as(users(:michael))
        expect {
          post microposts_path, params: { micropost: { content: "まさか、あんなことが起こるなんて" } }
          post microposts_path, params: { micropost: { content: "まさかり担いだ金太郎" } }
        }.to change(Micropost, :count)
        
        get search_path, params: { q: "まさか なんて" }
        expect(response.body).to include("まさか、あんなことが起こるなんて")
        expect(response.body).not_to include("まさかり担いだ金太郎")
      end


      it "全角スペースの接続" do
        log_in_as(users(:michael))
        expect {
          post microposts_path, params: { micropost: { content: "まさか、あんなことが起こるなんて" } }
          post microposts_path, params: { micropost: { content: "まさかり担いだ金太郎" } }
        }.to change(Micropost, :count)
        
        get search_path, params: { q: "まさか　なんて" }
        expect(response.body).to include("まさか、あんなことが起こるなんて")
        expect(response.body).not_to include("まさかり担いだ金太郎")
      end

      it "複数スペースの接続" do
        log_in_as(users(:michael))
        expect {
          post microposts_path, params: { micropost: { content: "まさか、あんなことが起こるなんて" } }
          post microposts_path, params: { micropost: { content: "まさかり担いだ金太郎" } }
        }.to change(Micropost, :count)
        
        get search_path, params: { q: "まさか 　なんて" }
        expect(response.body).to include("まさか、あんなことが起こるなんて")
        expect(response.body).not_to include("まさかり担いだ金太郎")
      end

      it "複数クエリの接続" do
        log_in_as(users(:michael))
        expect {
          post microposts_path, params: { micropost: { content: "まさか、あんなことが起こるなんて" } }
          post microposts_path, params: { micropost: { content: "まさかり担いだ金太郎" } }
        }.to change(Micropost, :count)
        
        get search_path, params: { q: "まさ か なん て" }
        expect(response.body).to include("まさか、あんなことが起こるなんて")
        expect(response.body).not_to include("まさかり担いだ金太郎")
      end
    end
  end
end
