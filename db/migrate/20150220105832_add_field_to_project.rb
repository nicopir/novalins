class AddFieldToProject < ActiveRecord::Migration
  def change
  	add_column :projects, :cost, :integer
  	add_column :projects, :instruction, :text
  	add_column :projects, :starting, :date
  	remove_column :projects, :confirmation, :boolean
  	remove_column :projects, :budget, :integer
  end
end
