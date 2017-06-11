class AddFieldToUser < ActiveRecord::Migration
  def change
  	add_column :users, :manager, :boolean, :default => false
  	add_column :users, :company_admin, :boolean, :default => false
  end
end
