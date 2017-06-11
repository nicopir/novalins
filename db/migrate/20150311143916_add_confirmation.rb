class AddConfirmation < ActiveRecord::Migration
  def change
  	add_column :projects, :confirmation, :boolean, :default => false
  end
end
