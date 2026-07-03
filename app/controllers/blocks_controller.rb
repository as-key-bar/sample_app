class BlocksController < ApplicationController

  def create
    user = User.find(params[:blocked_id])
    current_user.block(user)
    user.unfollow(current_user) if user.following?(current_user)
    current_user.unfollow(user) if current_user.following?(user)
    redirect_back(fallback_location: root_path) 
    # redirect_to user
  end

  def destroy
    block = current_user.active_blocks.find(params[:id])
    user = block.blocked
    current_user.unblock(user)
    redirect_back(fallback_location: root_path) 
    # redirect_to user, status: :see_other
  end

end
