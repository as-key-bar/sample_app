class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  belongs_to :user
  belongs_to :actor, class_name: "User"
end