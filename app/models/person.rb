class Person < ActiveRecord::Base
  versioned :initial_version => true

  has_many :partnerships, :dependent => :destroy, :finder_sql =>
    'SELECT DISTINCT ps.* '+
      'FROM partnerships ps '+
      'WHERE ps.person_id = #{id} OR ps.partner_id = #{id} '+
      'ORDER BY ps.date_started'
  has_many :partners, :class_name => 'Person', :finder_sql =>
    'SELECT DISTINCT p.*, ps.date_started AS partnership_date_started '+
      'FROM people p, partnerships ps '+
      'WHERE (ps.partner_id = #{id} AND ps.person_id = p.id) '+
        'OR (ps.person_id = #{id} AND ps.partner_id = p.id) '+
      'ORDER BY ps.date_started'
  has_many :defacto_partners, :class_name => 'Person', :finder_sql =>
    'SELECT DISTINCT person.*, child.date_of_birth AS partnership_date_started '+
      'FROM people person, people child '+
      'WHERE (child.father_id = #{id} AND child.mother_id = person.id) '+
        'OR  (child.mother_id = #{id} AND child.father_id = person.id) '+
      'ORDER BY child.date_of_birth'
  has_many :children_of_father, :class_name => 'Person', :foreign_key => 'father_id'
  has_many :children_of_mother, :class_name => 'Person', :foreign_key => 'mother_id'
  #named_scope :children, :include => [ :children_of_father, :children_of_mother ]
  belongs_to :mother, :class_name => 'Person'
  belongs_to :father, :class_name => 'Person'
  # named_scope :parents, { :include => [ :mother, :father ] }

  validates_length_of :name, :minimum => 1
  validates_inclusion_of :gender, :in => %w( male female ),
    :message => "must be specified"
  validates_date :date_of_birth, {
    :on_or_before => :today,
    :on_or_before_message => "must be before today",
    :on_or_before => :date_of_death,
    :on_or_before_message => "must be before date of death",
    :allow_blank => true
  }
  validates_date :date_of_death, {
    :on_or_before => :today,
    :on_or_before_message => "must be before today",
    :on_or_after => :date_of_birth,
    :on_or_after_message => "must be after date of birth",
    :allow_blank => true
  }
  validate :cannot_be_own_parent

  def cannot_be_own_parent
    if self == self.mother or self == self.father
      errors.add(:base, 'Cannot add a person as their own parent or child.')
    end
  end

  def children
    (self.children_of_father | self.children_of_mother).sort_by { |c|
      c.date_of_birth || Date.new(0)
    }
  end

  def children_with( person )
    if person == :unknown
      self.children.find_all { |child| !(child.mother_id && child.father_id) }
    else
      (self.children & person.children rescue []).sort_by { |c|
        c.date_of_birth || Date.new(0)
      }
    end
  end

  def children_ids
    self.children_of_father_ids | self.children_of_mother_ids
  end

  def add_child( child )
    if self.gender == 'male'
      self.children_of_father += [child]
    elsif self.gender == 'female'
      self.children_of_mother += [child]
    else
      errors.add(:base, 'Cannot determine person\'s gender.')
    end
  end

  def remove_child( child )
    if self.gender == 'male'
      self.children_of_father -= [child]
    elsif self.gender == 'female'
      self.children_of_mother -= [child]
    else
      errors.add(:base, 'Cannot determine person\'s gender.')
    end
  end

  def all_partners
    # Explicit partners override defacto partners in the union operation.
    # Then we sort by the date the partnership started, which in the
    # case of the defacto partners is the date their child was born.
    (partners | defacto_partners).sort_by { |p|
      p.partnership_date_started || ''
    }
  end

  def parents
    parents = []
    parents.push self.mother if self.mother
    parents.push self.father if self.father
    parents
  end

  def autocomplete_name
    dates_arr = []
    dates_arr << "b. #{self.date_of_birth.year}" rescue nil
    dates_arr << "d. #{self.date_of_death.year}" rescue nil
    if dates_arr.empty?
      dates = ""
    else
      dates = " [#{dates_arr.join(', ')}]"
    end
    "#{self.name}#{dates}"
  end

  def ancestry_json
    # add the person
    person = self.attributes.to_hash
    # add the children
    person['children'] = []
    self.children_of_father.each do |child|
      person['children'].push child.attributes.to_hash.merge({ 'data' => { '$orn' => 'top' } })
    end
    self.children_of_mother.each do |child|
      person['children'].push child.attributes.to_hash.merge({ 'data' => { '$orn' => 'top' } })
    end
    # add the partners
    self.partners.each do |partner|
      person['children'].push partner.attributes.to_hash.merge({ 'data' => { '$orn' => 'left' } })
    end
    # add the ancestors
    self.parents.each do |parent|
      # "children" here refers to descendents of the central object in the graph, not the genealogical
      # relationship. This line adds the current parent.
      person['children'].push parent.attributes.to_hash.merge({ 'data' => { '$orn' => 'bottom' } })
      # add the grandparents for this parent
      grandparents = person['children'].last['children'] = []
      parent.parents.each do |grandparent|
        grandparents.push grandparent.attributes.to_hash.merge({ 'data' => { '$orn' => 'bottom' } })
        # add the great grandparents for this grandparent
        great_grandparents = grandparents.last['children'] = []
        grandparent.parents.each do |great_grandparent|
          puts "great grandparent: #{great_grandparent.name}"
          great_grandparents.push great_grandparent.attributes.to_hash.merge({ 'data' => { '$orn' => 'bottom' } })
        end
      end
    end
    # return json
    person.to_json
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
