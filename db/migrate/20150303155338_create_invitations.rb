class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :company_id
      t.string :email

      t.timestamps null: false
    end
  end
end
