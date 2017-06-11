class AddFieldToUser2 < ActiveRecord::Migration
  def change
  	add_column :users, :department, :string
  	add_column :users, :mobile, :string
  	add_column :users, :contact_person, :string
  end
end
