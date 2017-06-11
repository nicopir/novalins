class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.string :status
      t.text :description
      t.integer :budget
      t.text :category
      t.text :urgency
      t.date :deadline

      t.timestamps null: false
    end
  end
end
