class PartnershipsController < ApplicationController
  respond_to :html, :xml, :json

  def create
    params[:partnership].delete(:name)
    @partnership = Partnership.new( params[:partnership] )

    if @partnership.save
      respond_with( @partnership, :status => :created, :location => @partnership ) do |format|
        format.html do
          if request.xhr?
            render :partial => "partnerships/show", :locals => { :partnership => @partnership }, :layout => false
          #else
            #redirect_to @partnership
          end
        end
      end
    else
      respond_with( @partnership.errors, :status => :unprocessable_entity ) do |format|
        format.html do
          if request.xhr?
            render :json => @partnership.errors
          #else
            #render :action => :new
          end
        end
      end
    end
  end

  def destroy
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { 
        if request.xhr?
          render :partial => "index"
        else
          redirect_to(people_url)
        end
      }
    end
  end
end
