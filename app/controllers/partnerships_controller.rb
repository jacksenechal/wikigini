class PartnershipsController < ApplicationController
  respond_to :html, :json

  def create
    errors = []
    name = params[:partnership].delete( :name )
    if name.blank?
      @partner = Person.find( params[:partnership][:partner_id] ) rescue nil
    else
      @partner = Person.find( :first, :conditions => [ "name LIKE '#{name}%%'" ] )
      errors.push "We can't find a person named \"#{name}\"" unless @partner
    end
    params[:partnership][:partner_id] = @partner.id rescue ''
    @partnership = Partnership.new( params[:partnership] )
    @person = Person.find( params[:partnership][:person_id] )
    respond_to do |format|
      if errors.empty? and @partnership.save
        puts "all good, y'all"
        format.html do
          render :partial => "people/partnership", 
            :locals => { :partnership => @partnership, :person => @person },
            :layout => false, :status => :ok
        end
      else
        puts "error! error! omg."
        errors += @partnership.errors.to_a
        format.json  { render :json => errors, :status => :unprocessable_entity }
      end
    end

#    if @partnership.save
#      respond_with( @partnership, :status => :created, :location => @partnership ) do |format|
#        format.html do
#          if request.xhr?
#            render :partial => "people/partnership", 
#              :locals => { :partnership => @partnership, :person => @person },
#              :layout => false
#          #else
#            #redirect_to @partnership
#          end
#        end
#      end
#    else
#      respond_with( @partnership.errors, :status => :unprocessable_entity ) do |format|
#        format.html do
#          if request.xhr?
#            render :json => @partnership.errors
#          #else
#            #render :action => :new
#          end
#        end
#      end
#    end
  end

  def destroy
    @partnership = Partnership.find( params[:id] )

    respond_to do |format|
      if @partnership.destroy
        format.html { 
          head :ok
        }
      else
        format.json  { render :json => @partnership.errors, :status => :unprocessable_entity }
      end
    end
  end
end
