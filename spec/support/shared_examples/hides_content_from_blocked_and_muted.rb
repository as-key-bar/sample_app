# 利用側は以下を定義すること:
#   viewer         - ブロック/ミュートする側のユーザー
#   author         - ブロック/ミュートされる側のユーザー(対象投稿の作者)
#   target_content - 一覧/レスポンス上で存在確認する文字列(投稿本文など)
#   perform_request - リクエストを実行するメソッド (レスポンスは response に入る想定)
RSpec.shared_examples "hides content from blocked and muted authors" do
  it "通常時は対象ユーザーの投稿が表示されること(前提条件)" do
    perform_request
    expect(response.body).to include(target_content)
  end

  it "ブロックしている相手の投稿が表示されないこと" do
    viewer.block(author)
    perform_request
    expect(response.body).not_to include(target_content)
  end

  it "ミュートしている相手の投稿が表示されないこと" do
    viewer.mute(author)
    perform_request
    expect(response.body).not_to include(target_content)
  end

  it "自分をブロックしている相手の投稿が表示されないこと" do
    author.block(viewer)
    perform_request
    expect(response.body).not_to include(target_content)
  end
end
