class NotificationsController < ApplicationController
  def index
    if !current_user.nil?
      blocking_ids = current_user.blocking.pluck(:id)
      @notifications = current_user.notifications
                                    .includes(:notifiable)
                                    .order(created_at: :desc)
      @notifications.set_read
      @notifications = @notifications.reject { |notification| blocking_ids.include?(notification.sender&.id) }
    else 
      redirect_to root_url
    end
  end
end
