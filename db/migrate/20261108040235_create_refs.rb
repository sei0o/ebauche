class CreateRefs < ActiveRecord::Migration[8.0]
  def change
    create_table :refs do |t|
      t.integer :kind, null: false, default: 0
      t.integer :drawable, null: false, default: 0
      t.text :memo
      t.string :source_url

      t.timestamps
    end
    add_index :refs, [ :kind, :created_at ]
  end
end
