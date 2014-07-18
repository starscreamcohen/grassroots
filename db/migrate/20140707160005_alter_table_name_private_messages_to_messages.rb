class AlterTableNamePrivateMessagesToMessages < ActiveRecord::Migration
  def change
    rename_table :private_messages, :messages
  end
end
