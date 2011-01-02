class Person < ActiveRecord::Base
  has_many :partnerships, :dependent => :destroy
  has_many :partners, :through => :partnerships, :source => :person
  belongs_to :mother, :class_name => "Person"
  belongs_to :father, :class_name => "Person"

  def children
    Person.find(:all, :conditions => ["father_id = ? OR mother_id = ?", self.id, self.id] )
  end

  def ancestry
    # add the person
    me = self.attributes.merge({ :gen => "0", :genindex => 0 })
    people = [me]

    # add their partners
    if self.partners
      genindex = 1
      partners.each do |p|
        people.push p.attributes.merge({ :gen => "0", :genindex => genindex })
        genindex += 1
      end
    end

    # add the parents
    if self.father
      people.push self.father.attributes.merge({ :gen => "-1", :genindex => 0 })
    end
    if self.mother
      people.push self.mother.attributes.merge({ :gen => "-1", :genindex => 1 })
    end

    # add the children
    if self.children
      genindex = 0
      self.children.each do |p|
        people.push p.attributes.merge({ :gen => "1", :genindex => genindex })
        genindex += 1
      end
    end

    people
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
