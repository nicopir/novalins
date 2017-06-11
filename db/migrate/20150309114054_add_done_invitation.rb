class AddDoneInvitation < ActiveRecord::Migration
  def change
  	add_column :invitations, :done, :boolean, :default => false
  end
end
