class DeleteJob < ActiveRecord::Migration
  def change
  	remove_column :projects, :job, :text
  end
end
