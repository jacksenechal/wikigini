class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.integer :father_id
      t.integer :mother_id
      t.string :name
      t.string :gender
      t.text :bio

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
