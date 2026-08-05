class NotificationsController < ApplicationController
  def index
    if !current_user.nil?
      @notifications = current_user.notifications.order(created_at: :desc)
    else 
      redirect_to root_url
    end
  end
end
