class Favorite < ApplicationRecord
  include Notifiable
  belongs_to :favoriter, class_name: "User"
  belongs_to :favorited, class_name: "Micropost"
  validates :favoriter_id, presence: true
  validates :favorited_id, presence: true
  validate :favorited_post_not_blocked, if: -> { favoriter && favorited }

  def notification_recipient
    favorited.user
  end
  def denied?
    favoriter == favorited.user
  end

  def actor
    favoriter
  end

  private

    def favorited_post_not_blocked
      return unless favoriter.interaction_blocked_with?(favorited.user)

      errors.add(:favorited, "cannot favorite a blocked user's post")
    end
end
