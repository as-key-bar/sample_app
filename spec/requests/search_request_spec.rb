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
      get search_path, params: { q: "まさか" }

      expect(response.body).to include("まさかあんなことが起こるとは思わなかった")
      expect(response.body).to include("まさかり担いだ金太郎")
      expect(response.body).to include("その「マサカ」が起こった")
      expect(response.body).not_to include("まっさかさまに落ちていった")
      expect(response.body).not_to include("masaka!")
      expect(response.body).not_to include("完全に無関係な文字列")
    end

    context "ファジーな検索" do
      it "検索対象はひらがな・全角カタカナ混じり文章/クエリはひらがな" do
        get search_path, params: { q: "こんかいはてすと" }
        expect(response.body).to include("今回はテストです")
      end
      it "検索対象はひらがな・全角カタカナ混じり文章/クエリはカタカナ" do
        get search_path, params: { q: "コンカイハテスト" }
        expect(response.body).to include("今回はテストです")
      end
      it "検索対象もクエリもひらがな・全角カタカナ混じり文章" do
        get search_path, params: { q: "今回はテスト" }
        expect(response.body).to include("今回はテストです")
      end

      it "検索対象はひらがな・半角カタカナ混じり文章：今回はﾃｽﾄです" do
        get search_path, params: { q: "こんかいはてすと" }
        expect(response.body).to include("今回はﾃｽﾄです")
      end
      it "検索対象はひらがな・半角カタカナ混じり文章/クエリは全半角まじりのカタカナ" do
        get search_path, params: { q: "ｺﾝｶｲハテスト" }
        expect(response.body).to include("今回はﾃｽﾄです")
      end
      it "検索対象もクエリもひらがな・半角カタカナ混じり文章" do
        get search_path, params: { q: "今回はテスト" }
        expect(response.body).to include("今回はﾃｽﾄです")
      end

      it "検索対象はひらがな・漢字混じり文章：クエリはひらがな" do
        get search_path, params: { q: "いまから" }
        expect(response.body).to include("今から提示する文章はテストなんです")
      end
      it "検索対象はひらがな・漢字混じり文章：クエリはカタカナ" do

        get search_path, params: { q: "イマカラ" }
        expect(response.body).to include("今から提示する文章はテストなんです")
      end
      it "検索対象はひらがな・漢字混じり文章：クエリは漢字ひらがな" do

        get search_path, params: { q: "居間から" }
        expect(response.body).to include("今から提示する文章はテストなんです")
      end

      it "検索対象は数字・ひらがな・数字混じり文章：クエリはひらがな" do
        get search_path, params: { q: "じゅうにけん" }
        expect(response.body).to include("テストに12件もテストを行います。十二件も、１２件もですよ")
      end
      it "検索対象は数字・ひらがな・漢字混じり文章：クエリはカタカナ" do

        get search_path, params: { q: "ジュウニケンモ" }
        expect(response.body).to include("テストに12件もテストを行います。十二件も、１２件もですよ")
      end
      it "検索対象は数字・ひらがな・漢字混じり文章：クエリは漢字ひらがな" do

        get search_path, params: { q: "十二件" }
        expect(response.body).to include("テストに12件もテストを行います。十二件も、１２件もですよ")
      end
    end

    context "AND検索のテスト" do
      it "半角スペースの接続" do        
        get search_path, params: { q: "まさか なんて" }
        expect(response.body).to include("まさか、あんなことが起こるなんて")
        expect(response.body).not_to include("まさかり担いだ金太郎")
      end


      it "全角スペースの接続" do
        get search_path, params: { q: "まさか　なんて" }
        expect(response.body).to include("まさか、あんなことが起こるなんて")
        expect(response.body).not_to include("まさかり担いだ金太郎")
      end

      it "複数スペースの接続" do
        get search_path, params: { q: "まさか 　なんて" }
        expect(response.body).to include("まさか、あんなことが起こるなんて")
        expect(response.body).not_to include("まさかり担いだ金太郎")
      end

      it "複数クエリの接続" do
        get search_path, params: { q: "まさ か なん て" }
        expect(response.body).to include("まさか、あんなことが起こるなんて")
        expect(response.body).not_to include("まさかり担いだ金太郎")
      end
    end
  end
end
