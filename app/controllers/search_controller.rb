class SearchController < ApplicationController
  def search
    @query = params[:query]
  end
end
