class NotificationsController < ApplicationController
  def index
    if !current_user.nil?
      blocking_ids = current_user.blocking.pluck(:id)
      @notifications = current_user.notifications
                                    .includes(:notifiable)
                                    .order(created_at: :desc)
                                    .reject { |notification| blocking_ids.include?(notification.sender&.id) }
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
