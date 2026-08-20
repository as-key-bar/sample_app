class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
    attr_accessor :remember_token, :activation_token, :reset_token
  before_save { self.email = email.downcase }

  has_many :active_mutes, class_name:  "Mute",
                                  foreign_key: "muter_id",
                                  dependent:   :destroy
  has_many :active_blocks, class_name:  "Block",
                                  foreign_key: "blocker_id",
                                  dependent:   :destroy
  has_many :passive_blocks, class_name:  "Block",
                                   foreign_key: "blocked_id",
                                   dependent:   :destroy
  has_many :muting, through: :active_mutes,  source: :muted
  has_many :blocking, through: :active_blocks, source: :blocked
  has_many :blocked, through: :passive_blocks, source: :blocking
  has_many :notifications, dependent: :destroy
  has_many :favorites, foreign_key: "favoriter_id", dependent: :destroy
  has_many :favorite_microposts, through: :favorites, source: :favorited

  before_save   :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続化セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end


  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # 有効化用メールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    # パスワードリセット用のメールを送信する
    def send_password_reset_email
      UserMailer.password_reset(self).deliver_now
    end

    # パスワードリセット用のダイジェストと送信時刻を作成する
    def create_reset_digest
      self.reset_token = User.new_token
      update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    # パスワードリセットの有効期限切れかどうかを返す
    def password_reset_expired?
      reset_sent_at < 2.hours.ago
    end
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # アカウントを有効化する
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # ユーザーのステータスフィードを返す
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    excluded_user_ids = (Block.where(blocker_id: id).pluck(:blocked_id) +
                          Mute.where(muter_id: id).pluck(:muted_id) +
                          Block.where(blocked_id: id).pluck(:blocker_id)).uniq
    excluded_microposts = Micropost.where(user_id: excluded_user_ids).reorder(nil).select(:id)

    Micropost
        .where("microposts.user_id IN (#{following_ids}) OR microposts.user_id = :user_id", user_id: id)
        .includes(:user, image_attachment: :blob, reposted_micropost: :user)
        .where.not(user_id: excluded_user_ids)
        .where.not(reposted_micropost_id: excluded_microposts)
  end

  # ユーザーをフォローする
  def follow(other_user)
    return false if blocked?(other_user)
    return false if self == other_user
    following << other_user
    true
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id)&.destroy
  end

  # 現在のユーザーが他のユーザーをフォローしていればtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end

  # ユーザーをミュートする
  def mute(other_user)
    unless muting?(other_user) || self == other_user
      muting << other_user
    end
  end

  # ユーザーをミュート解除する
  def unmute(other_user)
    if muting?(other_user)
      muting.delete(other_user)
    end
  end

  # 現在のユーザーが他のユーザーをミュートしていればtrueを返す
  def muting?(other_user)
    muting.include?(other_user)
  end

  # ユーザーをブロックする
  def block(other_user)
    unless blocking?(other_user) || self == other_user
      blocking << other_user
      self.unfollow(other_user) if following?(other_user)
      other_user.unfollow(self) if other_user.following?(self)
    end
  end

  # ユーザーをブロック解除する
  def unblock(other_user)
    blocking.delete(other_user)
  end

  # 現在のユーザーが他のユーザーをブロックしていればtrueを返す
  def blocking?(other_user)
    blocking.include?(other_user)
  end

  # 現在のユーザーが他のユーザーをブロックしていればtrueを返す
  def blocked?(other_user)
    other_user.blocking.include?(self)
  end

  def favorite(micropost)
    if !favoriting?(micropost)
      favorites.create(favorited_id: micropost.id)
    end
  end

  def unfavorite(micropost)
    if favoriting?(micropost)
      favorites.find_by(favorited_id: micropost.id).destroy
    end
  end

  def favoriting?(micropost)
    favorites.exists?(favorited_id: micropost.id)
  end

  def plain_reposted?(micropost)
    microposts.exists?(reposted_micropost_id: micropost.id, plain_repost: true)
  end

  def plain_repost_of(micropost)
    microposts.find_by(reposted_micropost_id: micropost.id, plain_repost: true)
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      self.email = email.downcase
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
