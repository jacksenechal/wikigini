class PeopleController < ApplicationController
  autocomplete :person, :name, :display_value => :autocomplete_name

  # GET /people
  def index
    @people = Person.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /people/1/versions
  def versions_index
    @person = Person.find( params[:id] )

    respond_to do |format|
      format.html # versions_index.html.erb
    end
  end

  # GET /people/1/versions/5
  def versions_show
    @person = Person.find( params[:id] )
    @person.revert_to( params[:version].to_i )
    puts "\n\n#{params[:version]} :: #{@person.version}\n\n"

    respond_to do |format|
      format.html { render "show" }
    end
  end

  # GET /people/1
  def show
    @person = Person.find( params[:id] )

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /people/new
  def new
    @person = Person.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /people
  def create
    @person = Person.new( params[:person] )
    respond_to do |format|
      if @person.save
        format.json { render :json => @person, :status => :ok }
        format.html { redirect_to @person }
      else
        format.json { render :json => @person.errors.to_a, :status => :unprocessable_entity }
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /people/1
  def update
    @person = Person.find( params[:id] )

    respond_to do |format|
      if @person.update_attributes( params[:person] )
        format.html { redirect_to(@person, :notice => 'Person was successfully updated.') }
        format.json  { render :json => @person, :status => :ok }
      else
        format.json { render :json => @person.errors.to_a, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1/update_mother
  def update_mother
    @person = Person.find( params[:id] )

    respond_to do |format|
      if @person.update_attributes( params[:person] )
        format.html { render :partial => "person", :locals => { :person => @person.mother }, :status => :ok }
      else
        format.json { render :json => @person.errors.to_a, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1/update_father
  def update_father
    @person = Person.find( params[:id] )

    respond_to do |format|
      if @person.update_attributes( params[:person] )
        format.html { render :partial => "person", :locals => { :person => @person.father }, :status => :ok }
      else
        format.json { render :json => @person.errors.to_a, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  def destroy
    @person = Person.find( params[:id] )
    @person.destroy

    respond_to do |format|
      format.html { redirect_to( people_url ) }
    end
  end
end
