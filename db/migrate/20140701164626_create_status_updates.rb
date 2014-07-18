class CreateStatusUpdates < ActiveRecord::Migration
  def change
    create_table :status_updates do |t|
      t.integer :user_id
      t.text :content
      t.timestamps
    end
  end
end
