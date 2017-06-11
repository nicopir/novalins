class ModifContactPerson2 < ActiveRecord::Migration
  def change
  	remove_column :users, :contact_person, :string
  	add_column :users, :contact_person, :string, :null => nil, :default => nil
  end
end
