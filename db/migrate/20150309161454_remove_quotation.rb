class RemoveQuotation < ActiveRecord::Migration
  def change
  	remove_column :projects, :quotation, :text
  end
end
