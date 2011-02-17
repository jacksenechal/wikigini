class PartnershipsController < ApplicationController
  respond_to :html, :json

  def create
    params[:partnership].delete(:partner_name)
    @partnership = Partnership.new( params[:partnership] )
    @person = Person.find( params[:partnership][:person_id] )
    respond_to do |format|
      if @partnership.save
        format.html do
          render :partial => "people/partnership", 
            :locals => { :partnership => @partnership, :person => @person },
            :layout => false, :status => :ok
        end
      else
        format.json  { render :json => @partnership.errors.to_a, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @partnership = Partnership.find( params[:id] )

    respond_to do |format|
      if @partnership.destroy
        format.json { head :ok }
      else
        format.json  { render :json => @partnership.errors, :status => :unprocessable_entity }
      end
    end
  end
end
