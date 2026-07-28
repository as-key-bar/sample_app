class Micropost < ApplicationRecord
  belongs_to :user


  has_many :passive_replys, class_name:  "MicropostReply",
                                  foreign_key: "reply_id",
                                  dependent:   :destroy
  has_many :reply, through: :passive_replys, source: :reply_to

  has_one :active_replys, class_name:  "MicropostReply",
                                   foreign_key: "reply_to_id",
                                   dependent:   :destroy
  has_one :reply_to, through: :active_replys,  source: :reply

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

  def set_reply_to(micropost)
    return false if micropost.nil?
    self.reply_to = micropost
    self.save
  end

end
