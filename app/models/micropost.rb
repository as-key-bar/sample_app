class Micropost < ApplicationRecord
  include Notifiable
  belongs_to :user

  belongs_to :reply_to, class_name: "Micropost", optional: true
  has_many :replies, class_name: "Micropost", foreign_key: "reply_to_id", dependent: :nullify

  belongs_to :reposted_micropost, class_name: "Micropost", optional: true
  has_many :reposts, class_name: "Micropost", foreign_key: "reposted_micropost_id", dependent: :destroy

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  has_many :favorites, foreign_key: "favorited_id", dependent: :destroy

  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                      size: { less_than: 5.megabytes,
                              message:   "should be less than 5MB" }


  def notification_recipient
    User.find_by(id: self.reply_to.user_id)
  end
  def denied?
    reply_to.nil?
  end
end
