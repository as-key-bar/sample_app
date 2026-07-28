class CreateMicropostReplies < ActiveRecord::Migration[7.0]
  def change
    create_table :micropost_replies do |t|
      t.integer :reply
      t.integer :reply_to

      t.timestamps
    end
  end
end
