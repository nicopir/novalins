class ModifContactPerson < ActiveRecord::Migration
  def change
  	remove_column :users, :contact_person, :string
  	add_column :users, :contact_person, :string, :null => false, :default => false
  end
end
