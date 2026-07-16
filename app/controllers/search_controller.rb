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
    @microposts = Micropost.where("content LIKE ?", "%#{@query}%").paginate(page: params[:page], per_page: 10)

    render 'search_result'
  end
end
