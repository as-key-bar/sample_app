class SearchController < ApplicationController
  def search
    if @query = params[:q]
      search_results
    else
      @title = "Search"
     render 'search'
    end
  end

  def search_results
    @title = "Search Results of #{@query}"
    @microposts_dmy = [
      Micropost.new(id: 1, content: "これはテスト投稿1です。", user_id: 1, created_at: Time.current),
      Micropost.new(id: 2, content: "これはテスト投稿2です。", user_id: 1, created_at: Time.current),
      Micropost.new(id: 3, content: "これはテスト投稿3です。", user_id: 1, created_at: Time.current)
    ]


    @microposts = WillPaginate::Collection.create(1, 10, @microposts_dmy.length) do |pager|
      pager.replace(@microposts_dmy)
    end

    render 'search_result'

  end
end
