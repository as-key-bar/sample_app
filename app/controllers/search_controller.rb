class SearchController < ApplicationController
  def search
    # @query = params[:query]
    @title = "Search"
    render 'search'
  end

  # def search_results
  #   @query = params[:query]
  #   render 'search_results'
  # end
end
