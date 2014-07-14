class CreateTalents < ActiveRecord::Migration
  def change
    create_table :talents do |t|
      t.integer :skill_id
      t.integer :user_id
    end
  end
end
