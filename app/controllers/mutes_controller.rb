class MutesController < ApplicationController
  def create
    user = User.find(params[:muted_id])
    current_user.mute(user)
    # redirect_to user
    redirect_back(fallback_location: root_path) 
  end

  def destroy
    mute = current_user.active_mutes.find(params[:id])
    user = mute.muted
    current_user.unmute(user)
    # redirect_to user, status: :see_other
    redirect_back(fallback_location: root_path) 
  end
end