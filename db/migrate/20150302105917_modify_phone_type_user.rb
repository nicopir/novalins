class ModifyPhoneTypeUser < ActiveRecord::Migration
  def change
  	remove_column :users, :phone, :integer
	add_column :users, :phone, :string
  end
end
