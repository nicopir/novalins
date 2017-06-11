class AddBelongUserProject < ActiveRecord::Migration
  def change
  	add_column :projects, :project_manager_id, :integer
  	add_column :projects, :project_owner_id, :integer
  	remove_column :projects, :user_id, :integer
  end
end
