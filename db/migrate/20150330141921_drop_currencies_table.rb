class DropCurrenciesTable < ActiveRecord::Migration
  def change
  	drop_table :currencies
  end
end
