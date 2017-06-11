class CreateCurrencies2 < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
		t.string :title
    end
  end
end
