class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: true
      t.string :password_digest
      t.integer :role, default: 0

      t.timestamps
    end
  end
end