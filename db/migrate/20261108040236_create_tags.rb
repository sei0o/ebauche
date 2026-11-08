class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.integer :category, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :tags, [ :category, :name ], unique: true
  end
end
