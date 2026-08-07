class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  def sender
    if notifiable = Relationship
      notifiable.follower
    elsif notifiable = Micropost
      notifiable.user
    end
  end

  def self.set_read
    update_all(read: true)
  end
end