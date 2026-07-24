class SearchController < ApplicationController
  include TextNormalizer
  def search
    @query = params[:q]
    if @query.present?
      search_results
    else
      @title = "Search"
     render 'search'
    end
  end

  def search_results
    return if !@query 
    @title = "Search Results of #{@query}"
    @microposts = Micropost.where("searchkey LIKE ?", "%#{convert_to_searchkey(@query)}%").paginate(page: params[:page], per_page: 10)

    render 'search_result'
  end
end
