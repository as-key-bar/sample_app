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
    render 'search_result'
    @microposts = Micropost.find_by(id: 1)
  end
end
