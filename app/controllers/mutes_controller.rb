class MutesController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by(id: params[:muted_id])

    if @user.nil? || !current_user.mute(@user)
      respond_to do |format|
        format.html do
          flash[:warning] = "This user could not be muted."
          redirect_back(fallback_location: root_path)
        end
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
    mute = current_user.active_mutes.find_by(id: params[:id])

    if mute
      @user = mute.muted
      current_user.unmute(@user)
      respond_to do |format|
        format.html { redirect_to @user, status: :see_other }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path) }
        format.turbo_stream { head :ok }
      end
    end
  end
end
