class Partnership < ActiveRecord::Base
  belongs_to :person, :class_name => 'Person', :foreign_key => :person_id
  belongs_to :partner, :class_name => 'Person', :foreign_key => :partner_id

  validates_presence_of :person, :partner
  validates_uniqueness_of :partner_id, :scope => :person_id, :message => 'already exists.'
  validate :cannot_add_self

  def cannot_add_self
    errors.add(:base, 'Cannot add a person as their own partner.') if self.person == self.partner
  end

  def partner_of_person(someone)
    return partner if someone == person
    return person if someone == partner
    return false
  end
end
