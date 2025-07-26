class CreateTestTable < ActiveRecord::Migration[8.0]
  def change
    create_table :test_tables do |t|
      t.integer :id
      t.string :name

      t.timestamps
    end
  end
end
