class CreateTabs < ActiveRecord::Migration[5.2]
  def change
    create_table :tabs do |t|
      t.references :user, foreign_key: true
      t.string :url, null: false
      t.string :title

      t.timestamps
    end
  end
end
