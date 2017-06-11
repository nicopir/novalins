class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :file_path
      t.integer :project_id
      t.string :name

      t.timestamps null: false
    end
  end
end
