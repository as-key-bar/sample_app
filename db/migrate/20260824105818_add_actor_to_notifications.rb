class AddActorToNotifications < ActiveRecord::Migration[7.0]
  def up
    add_column :notifications, :actor_id, :integer

    Notification.reset_column_information
    Notification.find_each do |notification|
      actor = case notification.notifiable_type
              when "Relationship" then notification.notifiable&.follower
              when "Micropost"    then notification.notifiable&.user
              when "Favorite"     then notification.notifiable&.favoriter
              end
      raise "actor not resolved for notification #{notification.id}" if actor.nil?

      notification.update_column(:actor_id, actor.id)
    end

    change_column_null :notifications, :actor_id, false
    add_index :notifications, [:user_id, :actor_id]
    add_foreign_key :notifications, :users, column: :actor_id
  end

  def down
    remove_foreign_key :notifications, :users, column: :actor_id
    remove_index :notifications, [:user_id, :actor_id]
    remove_column :notifications, :actor_id
  end
end
