class MessageRead < ActiveRecord::Migration
  def change
  	remove_column :messages, :read, :boolean
  	add_column :messages, :read, :boolean, :default => false
  end
end
