class MutesController < ApplicationController
  before_action :logged_in_user
  def create
    if !current_user.muting?(@user)
      unless !User.exists?(params[:muted_id]) || current_user.id == params[:muted_id].to_i
        user = User.find(params[:muted_id])
        current_user.mute(user)
        # redirect_to user
        redirect_back(fallback_location: root_path) 
      else
        redirect_to root_path, status: :bad_request
      end
    end
  end

  def destroy
    mute = current_user.active_mutes.find_by(id: params[:id])

    unless mute.nil?
      target_user = mute.muted
      if current_user.muting?(target_user)
        current_user.unmute(target_user)
      end
    end
    redirect_back(fallback_location: root_path)
  end
end