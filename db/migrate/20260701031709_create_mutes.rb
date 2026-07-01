class CreateMutes < ActiveRecord::Migration[7.0]
  def change
    create_table :mutes do |t|
      t.integer :muter_id
      t.integer :muted_id

      t.timestamps
    end
  end
end
