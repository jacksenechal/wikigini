class Person < ActiveRecord::Base
  has_many :partnerships, :dependent => :destroy
  has_many :partners, :through => :partnerships, :source => :person
  has_many :children_of_father, :class_name => 'Person', :foreign_key => 'father_id'
  has_many :children_of_mother, :class_name => 'Person', :foreign_key => 'mother_id'
  #named_scope :children, :include => [ :children_of_father, :children_of_mother ]
  belongs_to :mother, :class_name => 'Person'
  belongs_to :father, :class_name => 'Person'
  # named_scope :parents, { :include => [ :mother, :father ] }

  def children
    self.children_of_father | self.children_of_mother
  end

  def parents
    parents = []
    parents.push self.mother if self.mother
    parents.push self.father if self.father
    parents
  end

  def ancestry_json
    # add the person
    people = self.attributes.to_hash
    # add the children
    people['children'] = []
    self.children_of_father.each do |child|
      people['children'].push child.attributes.to_hash.merge({ 'data' => { '$orn' => 'top' } })
    end
    self.children_of_mother.each do |child|
      people['children'].push child.attributes.to_hash.merge({ 'data' => { '$orn' => 'top' } })
    end
    # add the partners
    self.partners.each do |partner|
      people['children'].push partner.attributes.to_hash.merge({ 'data' => { '$orn' => 'left' } })
    end
    # add the parents
    self.parents.each do |parent|
      people['children'].push parent.attributes.to_hash.merge({ 'data' => { '$orn' => 'bottom' } })
    end
    # return json
    people.to_json
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
