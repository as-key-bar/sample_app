class CreateFavorites < ActiveRecord::Migration[7.0]
  def change
    create_table :favorites do |t|
      t.integer :favoriter_id
      t.integer :favorited_id
      t.timestamps
    end
    add_index :favorites, :favoriter_id
    add_index :favorites, :favorited_id
    add_index :favorites, [:favoriter_id, :favorited_id], unique: true
  end
end
