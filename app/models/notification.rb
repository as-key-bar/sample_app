class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  belongs_to :user

  def sender
    case notifiable_type
    when "Relationship"
      notifiable.follower
    when "Micropost"
      notifiable.user
    when "Favorite"
      notifiable.favoriter
    end
  end
end