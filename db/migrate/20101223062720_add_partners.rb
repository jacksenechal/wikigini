class AddPartners < ActiveRecord::Migration
  def self.up
    create_table :partners do |t|
      t.integer :person_id
      t.integer :partner_id
      t.integer :order
      t.string  :nature # married, children
      t.boolean :current
    end
  end

  def self.down
    drop_table :partners
  end
end
