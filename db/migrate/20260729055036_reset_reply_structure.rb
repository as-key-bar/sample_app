class ResetReplyStructure < ActiveRecord::Migration[7.0]
  def change
    drop_table :micropost_replies do |t|
      t.integer :reply
      t.integer :reply_to
      t.timestamps
    end

    add_reference :microposts, :reply_to, foreign_key: { to_table: :microposts }, null: true
  end
end