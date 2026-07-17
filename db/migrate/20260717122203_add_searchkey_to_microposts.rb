class AddSearchkeyToMicroposts < ActiveRecord::Migration[7.0]
  def change
    add_column :microposts, :searchkey, :string
  end
end
