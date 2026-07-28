class MicropostReply < ApplicationRecord
  belongs_to :reply_to, class_name: "Micropost"
  belongs_to :reply, class_name: "Micropost"
  validates :reply, presence: true
  validates :reply_to, presence: true
end