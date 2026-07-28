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
    follow_only = params[:follow_only] == "1" 

    if current_user && follow_only
      target_user_ids = current_user.following.map(&:id)
      target_user_ids << current_user.id
    end
    
    scope = Micropost.all
    @microposts = queries.reduce(scope) do |result, q|
      searchkey = convert_to_searchkey(q)
      if current_user && follow_only
        result.where(user_id: target_user_ids)
              .where("searchkey LIKE ? OR searchkey LIKE ?", "%#{searchkey}%", "%#{q}%")
      else
        result.where("searchkey LIKE ? OR searchkey LIKE ?", "%#{searchkey}%", "%#{q}%")
      end
    end.paginate(page: params[:page], per_page: 10)

    render 'search_result'
  end
end
