class Micropost < ApplicationRecord
  include Notifiable
  belongs_to :user

  belongs_to :reply_to, class_name: "Micropost", optional: true
  has_many :replies, class_name: "Micropost", foreign_key: "reply_to_id", dependent: :nullify

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size: { less_than: 5.megabytes,
                              message:   "should be less than 5MB" }


  def notification_recipient
    reply_to.user
  end
  def denied?
    reply_to.present?
  end
end
