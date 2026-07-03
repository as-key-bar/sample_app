class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    
    unless current_user.follow(@user)
      message  = "This user was blocked or you are trying to follow yourself."
      flash[:warning] = message
      render 'new', status: :unprocessable_entity

      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, alert: "フォローできません") }
        format.turbo_stream { head :unprocessable_entity }
      end
      return
    end
    
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
