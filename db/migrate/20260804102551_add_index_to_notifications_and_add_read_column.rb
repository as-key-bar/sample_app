class AddIndexToNotificationsAndAddReadColumn < ActiveRecord::Migration[7.0]
  def change
    add_index :notifications, [:user_id, :created_at]
    remove_index :notifications, :user_id
    add_column :notifications, :read, :boolean, null: false, default: false
  end
end
