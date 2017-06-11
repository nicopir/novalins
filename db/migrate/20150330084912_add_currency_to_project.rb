class AddCurrencyToProject < ActiveRecord::Migration
  def change
  	add_column :projects, :currency_id, :integer, :default => nil
  end
end
