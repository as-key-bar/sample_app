module Notifiable
  extend ActiveSupport::Concern

  included do
    has_one :notification, as: :notifiable, dependent: :destroy
    after_create_commit :create_notifications
  end

  private
  def denied?
    false
  end

  def create_notifications
    return if denied? 
    notification = Notification.create(notifiable: self, user: notification_recipient)
    notification.save!
  end
end

