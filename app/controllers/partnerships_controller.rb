class PartnershipsController < ApplicationController
  respond_to :html, :json

  def create
    params[:partnership].delete(:name)
    respond_with( @partnership = Partnership.create( params[:partnership] ) ) do |format|
      format.html do
        if request.xhr?
          if @partnership.errors
            render :json => @partnership.errors
          else
            render :partial => "people/partnership", 
              :locals => { :partnership => @partnership, :person => @person },
              :layout => false
          end
        end
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
    @partnership.destroy

    respond_to do |format|
      format.html { 
        if request.xhr?
          render :partial => "partnerships"
        #else
          #redirect_to( people_path ) )
        end
      }
    end
  end
end
