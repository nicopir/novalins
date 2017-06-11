class CreateOutputFiles < ActiveRecord::Migration
  def change
    create_table :output_files do |t|
      t.string :file_path
      t.integer :project_id
      t.string :name

      t.timestamps null: false
    end
  end
end
