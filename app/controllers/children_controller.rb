class ChildrenController < ApplicationController
  # POST /people/1/children
  def create
    @person = Person.find( params[:person_id] )
    @child = Person.find( params[:child][:child_id] )
    @person.add_child( @child )
    respond_to do |format|
      if @person.save
        format.html do
          render :partial => "people/child", 
            :locals => { :child => @child, :person => @person },
            :layout => false, :status => :ok
        end
      else
        format.json { render :json => @person.errors.to_a, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1/children
  def destroy
    @person = Person.find( params[:person_id] )
    @child = Person.find( params[:id] )
    @person.remove_child( @child )

    respond_to do |format|
      if @person.save
        format.json { head :ok }
        format.html { redirect_to @person }
      else
        format.json { render :json => @person.errors.to_a, :status => :unprocessable_entity }
      end
    end
  end
end
