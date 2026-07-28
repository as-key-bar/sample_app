class RenameColumnsInMicropostReplies < ActiveRecord::Migration[7.0]
  def change
    rename_column :micropost_replies, :reply, :reply_id
    rename_column :micropost_replies, :reply_to, :reply_to_id
  end
end
