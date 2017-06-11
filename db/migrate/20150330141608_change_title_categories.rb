class ChangeTitleCategories < ActiveRecord::Migration
  def change
  	remove_column :categories, :title, :string
  	add_column :categories, :name, :string, :default => nil
  end
end
