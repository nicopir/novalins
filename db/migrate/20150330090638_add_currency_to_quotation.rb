class AddCurrencyToQuotation < ActiveRecord::Migration
  def change
	add_column :quotations, :currency_id, :integer, :default => nil
  end
end
