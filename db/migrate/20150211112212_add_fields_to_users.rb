class AddFieldsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :address, :string
    add_column :users, :location, :string
    add_column :users, :phone, :integer
  end
end
