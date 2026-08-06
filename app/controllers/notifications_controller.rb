class NotificationsController < ApplicationController
  def index
    if !current_user.nil?
      blocking_ids = current_user.blocking.pluck(:id)
      blocked_relationship_ids = Relationship.where(follower_id: current_user.blocking.select(:id)).select(:id)
      blocked_micropost_ids    = Micropost.where(user_id: current_user.blocking.select(:id)).select(:id)

      @notifications = current_user.notifications
                                    .includes(:notifiable)
                                    .where.not(notifiable_type: "Relationship", notifiable_id: blocked_relationship_ids)
                                    .where.not(notifiable_type: "Micropost",    notifiable_id: blocked_micropost_ids)
                                    .order(created_at: :desc)
                                    .paginate(page: params[:page], per_page: 10)

    else
      redirect_to root_url
    end
  end

  def read
    if !current_user.nil?
      current_user.notifications.set_read
      head :no_content
    else
      redirect_to root_url
    end
  end
end
