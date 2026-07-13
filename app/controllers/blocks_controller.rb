class BlocksController < ApplicationController
  before_action :logged_in_user
  def create

    #idのバリデーション
    if !params[:blocked_id].to_s.match?(/\A\d+\z/)
      redirect_to root_path, status: :bad_request
      return
    elsif current_user.id == params[:blocked_id].to_i
      redirect_to root_path, status: :bad_request
      return
    end

    if user = User.find_by(id: params[:blocked_id])
        current_user.block(user)
        redirect_back(fallback_location: root_path) 
    else
      redirect_to root_path, status: :not_found
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
