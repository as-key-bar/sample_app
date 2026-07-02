class BlocksController < ApplicationController

  def create
    user = User.find(params[:blocked_id])
    current_user.block(user)
    redirect_to user
  end

  def destroy
    block = current_user.active_blocks.find(params[:id])
    user = block.blocked
    current_user.unblock(user)
    redirect_to user, status: :see_other
  end

end
