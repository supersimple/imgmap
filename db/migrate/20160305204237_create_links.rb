class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :job_id
      t.text :url
      t.text :images, array: true, default: []
      t.boolean :complete, default: false

      t.timestamps null: false
    end
  end
end
