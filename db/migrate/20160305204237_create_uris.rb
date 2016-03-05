class CreateUris < ActiveRecord::Migration
  def change
    create_table :uris do |t|
      t.integer :job_id
      t.text :url
      t.text :images, array: true, default: []
      t.boolean :complete, deafult: false

      t.timestamps null: false
    end
  end
end
