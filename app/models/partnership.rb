class Partnership < ActiveRecord::Base
  belongs_to :person, :class_name => 'Person', :foreign_key => :person_id
  belongs_to :partner, :class_name => 'Person', :foreign_key => :partner_id

  validates_presence_of :person, :partner

  def partner_of_person(someone)
    return partner if someone == person
    return person if someone == partner
    return false
  end
end
