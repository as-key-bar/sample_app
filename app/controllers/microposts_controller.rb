class MicropostsController < ApplicationController
  include TextNormalizer

  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    @micropost.searchkey = convert_to_searchkey(params[:micropost][:content])

    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_back_or_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    if request.referrer.nil? || request.referrer == microposts_url
      redirect_to root_url, status: :see_other
    else
      redirect_to request.referrer, status: :see_other
    end
  end

  def show  
    @micropost = Micropost.find(params[:id])  
    if logged_in? && current_user.blocked?(@micropost.user)
      flash[:danger] = "You are blocked by this user"
      redirect_back(fallback_location: root_url)
    else
      @replies = @micropost.replies.paginate(page: params[:page])
      @reply_micropost = current_user.microposts.build
    end
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :image, :reply_to_id, :reposted_micropost_id)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil?
    end
end
