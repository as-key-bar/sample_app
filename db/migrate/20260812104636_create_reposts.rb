class CreateReposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :reposted_micropost_id, :integer
    add_column :microposts, :plain_repost, :boolean, default: false, null: false

    add_index :microposts, :reposted_micropost_id
    add_index :microposts, [:user_id, :reposted_micropost_id],
              unique: true,
              where: "plain_repost = TRUE",
              name: "index_microposts_on_plain_repost_uniqueness"

    add_foreign_key :microposts, :microposts, column: :reposted_micropost_id
  end
end
