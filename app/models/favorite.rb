class Favorite < ApplicationRecord
  # include Notifiable
  belongs_to :favoriter, class_name: "User"
  belongs_to :favorited, class_name: "Micropost"
  validates :favoriter_id, presence: true
  validates :favorited_id, presence: true

  # def notification_recipient
  #   favorited.user
  # end
end
