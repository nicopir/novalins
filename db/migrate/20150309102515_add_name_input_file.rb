class AddNameInputFile < ActiveRecord::Migration
  def change
  	add_column :input_files, :name, :string, :default => nil
  end
end
