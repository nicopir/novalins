class RemoveInvoice < ActiveRecord::Migration
  def change
  	remove_column :projects, :invoice, :text
  end
end
