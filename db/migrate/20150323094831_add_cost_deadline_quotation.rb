class AddCostDeadlineQuotation < ActiveRecord::Migration
  def change
  	add_column :quotations, :cost, :integer, :default => nil
  	add_column :quotations, :deadline, :date, :default => nil
  end
end