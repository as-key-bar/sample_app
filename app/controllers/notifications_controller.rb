class NotificationsController < ApplicationController
  def index
    if current_user.present?
      @notifications = current_user.notifications
                                    .where.not(actor_id: current_user.visibility_excluded_user_ids)
                                    .includes(notifiable: [:follower, :user])
                                    .order(created_at: :desc)
                                    .paginate(page: params[:page], per_page: 10)

    else
      redirect_to root_url
    end
  end

  def read
    if current_user.present?
      current_user.notifications.update_all(read: true)
      head :no_content
    else
      redirect_to root_url
    end
  end
end
