class ModifProjectCategory < ActiveRecord::Migration
  def change
	remove_column :projects, :category, :string
	add_column :projects, :category_id, :integer
  end
end
