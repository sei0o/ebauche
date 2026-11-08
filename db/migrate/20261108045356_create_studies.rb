class CreateStudies < ActiveRecord::Migration[8.0]
  def change
    create_table :studies do |t|
      t.references :ref, null: false, foreign_key: true
      t.integer :minutes
      t.text :memo

      t.timestamps
    end
  end
end
