class AddFieldsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :quotation, :text
    add_column :projects, :invoice, :text
    add_column :projects, :confirmation, :boolean
    add_column :projects, :job, :text
  end
end
