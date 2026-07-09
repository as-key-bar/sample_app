class BlocksController < ApplicationController
  before_action :logged_in_user
  def create
    if !current_user.blocking?(@user)
      unless !User.exists?(params[:blocked_id]) || current_user.id == params[:blocked_id].to_i
        user = User.find(params[:blocked_id])
        current_user.block(user)
        # redirect_to user
        redirect_back(fallback_location: root_path) 
      else
        redirect_to root_path, status: :bad_request
      end
    end
  end

  def destroy
    block = current_user.active_blocks.find_by(id: params[:id])

    unless block.nil?
      target_user = block.blocked
      if current_user.blocking?(target_user)
        current_user.unblock(target_user)
      end
    end
    redirect_back(fallback_location: root_path)
  end

end
