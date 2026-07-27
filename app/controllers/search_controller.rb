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

    queries = @query.strip.split(/[[:blank:]]+/)

    scope = Micropost.all
    @microposts = queries.reduce(scope) do |result, q|
      searchkey = convert_to_searchkey(q)
      result.where("searchkey LIKE ? OR searchkey LIKE ?", "%#{searchkey}%", "%#{q}%")
    end.paginate(page: params[:page], per_page: 10)

    render 'search_result'
  end
end
