class FavoritesController < ApplicationController
  def create
    @favorited_post = Micropost.find(params[:favorited_id])
    if current_user.present?
      current_user.favorite(@favorited_post)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.turbo_stream
      end
    else
      redirect_back_or_to root_path, alert: "You need to log in to favorite posts."
    end
  end

  def destroy
    if current_user.present?
      @favorited_post = Favorite.find(params[:id]).favorited
      current_user.unfavorite(@favorited_post)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.turbo_stream
      end
    end
  end
end
