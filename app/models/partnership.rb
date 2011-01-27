class Partnership < ActiveRecord::Base
  belongs_to :person, :class_name => 'Person'
  belongs_to :partner, :class_name => 'Person', :foreign_key => :partner_id
end
