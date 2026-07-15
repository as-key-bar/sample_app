class SearchController < ApplicationController
  def search
    # @query = params[:query]
    @title = "Search"
    render 'search'
  end
end
