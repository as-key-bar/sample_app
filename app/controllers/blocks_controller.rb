class BlocksController < ApplicationController
  before_action :logged_in_user
  def create
    if User.exists?(params[:blocked_id]) && current_user.id != params[:blocked_id].to_i
        user = User.find(params[:blocked_id])
        current_user.block(user)
        redirect_back(fallback_location: root_path) 
    else
      redirect_to root_path, status: :bad_request
    end
  end

  def destroy
    if block = current_user.active_blocks.find_by(id: params[:id])
      target_user = block.blocked
      current_user.unblock(target_user)
    end
    redirect_back(fallback_location: root_path)
  end

end
