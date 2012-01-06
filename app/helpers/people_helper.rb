module PeopleHelper
  def tree_node(person)
    render :partial => "tree_node", :locals => { :person => person }
  end

  def children_with_partner(partner)
    if !partner.nil?
      children_html = []
      @person.children_with(partner).each do |child|
        children_html.push tree_node(child)
      end
      if !children_html.empty?
        separator_html = '<div class="node_separator"></div>'
        concat (separator_html + children_html.join(separator_html)).html_safe
      end
    end
    nil
  end

  def children_with_unknown
    @person.children_with_unknown.each do |child|
      concat tree_node(child)
    end
  end
end
