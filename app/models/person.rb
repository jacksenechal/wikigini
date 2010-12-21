class Person < ActiveRecord::Base
  belongs_to :mother, :class_name => "Person"
  belongs_to :father, :class_name => "Person"

  def children
    Person.find(:all, :conditions => { :father_id => self.id })
  end

  def self.men(conditions = {})
    conditions = conditions.merge({ :gender => "male" })
    Person.find(:all, :conditions => conditions)
  end

  def self.women(conditions = {})
    conditions = conditions.merge({ :gender => "female" })
    Person.find(:all, :conditions => conditions)
  end

end
