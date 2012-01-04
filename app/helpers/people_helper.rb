module PeopleHelper
  def tree_node(person)
    render :partial => "tree_node", :locals => { :person => person }
  end

  def children_with_partner(partner)
    if !partner.nil?
      @person.children_with(partner).each do |child|
        concat(tree_node child)
      end
    end
    nil
  end

  def children_with_unknown
    @person.children_with_unknown.each do |child|
      concat(tree_node child)
    end
  end
end
