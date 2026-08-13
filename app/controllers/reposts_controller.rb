class RepostsController < ApplicationController
  def create
    @reposted_micropost = Micropost.find(params[:reposted_micropost_id])
    if current_user.present?
      @repost = current_user.microposts.build(
        reposted_micropost: @reposted_micropost,
        plain_repost: true
      )
      if @repost.save
        respond_to do |format|
          format.html { redirect_back_or_to root_path }
          format.turbo_stream
        end
      else
        redirect_back_or_to root_path, alert: @repost.errors.full_messages.to_sentence
      end
    else
      redirect_back_or_to root_path, alert: "You need to log in to repost."
    end
  end

  def destroy
    @repost = current_user.microposts.find_by(id: params[:id])
    if @repost.present?
      @reposted_micropost = @repost.reposted_micropost
      @repost.destroy
      respond_to do |format|
        format.html { redirect_back_or_to root_path }
        format.turbo_stream
      end
    else
      redirect_back_or_to root_path
    end
  end
end
