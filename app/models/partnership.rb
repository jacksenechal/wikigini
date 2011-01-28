class Partnership < ActiveRecord::Base
  belongs_to :person1, :class_name => 'Person', :foreign_key => :person_id
  belongs_to :person2, :class_name => 'Person', :foreign_key => :partner_id

  validates_presence_of :person1, :person2

  def partner_of_person(person)
    return person2 if person == person1
    return person1 if person == person2
    return false
  end
end
