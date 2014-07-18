class AddColumnSmallCoverToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :small_cover, :string
  end
end
