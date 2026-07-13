class MutesController < ApplicationController
  before_action :logged_in_user

  def create
    #idのバリデーション
    if !params[:muted_id].to_s.match?(/\A\d+\z/)
      redirect_to root_path, status: :bad_request
      return
    elsif current_user.id == params[:muted_id].to_i
      redirect_to root_path, status: :bad_request
      return
    end

    if user = User.find_by(id: params[:muted_id])
      current_user.mute(user)
      redirect_back(fallback_location: root_path) 
    else
      redirect_to root_path, status: :not_found
    end

  end

  def destroy
    if mute = current_user.active_mutes.find_by(id: params[:id])
      target_user = mute.muted
      current_user.unmute(target_user)
    end
    redirect_back(fallback_location: root_path)
  end
end