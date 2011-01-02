class CreatePartnerships < ActiveRecord::Migration
  def self.up
    drop_table :partners
    create_table :partnerships do |t|
      t.integer :person_id
      t.integer :partner_id
      t.date    :date_started
      t.date    :date_ended
      t.string  :nature # married, children
    end
  end

  def self.down
    drop_table :partnerships
    create_table :partners do |t|
      t.integer :person_id
      t.integer :partner_id
      t.integer :order
      t.string  :nature # married, children
      t.boolean :current
    end
  end
end
