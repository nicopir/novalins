class CreateInputFiles < ActiveRecord::Migration
  def change
    create_table :input_files do |t|
      t.string :file_path
      t.integer :project_id

      t.timestamps null: false
    end
  end
end
