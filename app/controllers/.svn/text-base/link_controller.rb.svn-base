class LinkController < ApplicationController
	def index
		@analyzers=Analyzer.paginate :page => params[:page], :per_page => 10
	end
	
	def conn_analyzer
		if (params.key?(:id)) && !params[:id].nil?
			ana=Analyzer.find(params[:id])
			if (ana.status==10)
			    if ana.api_url.nil? or ana.api_url.length == 0
				  redirect_to "http://"+ana.ip.to_s
				else
                  redirect_to ana.api_url.to_s			
				end
			else
				flash[:error]="please disconnect analyzer first."
				redirect_to :action => "index"
			end
				
		else
		    flash[:error]="error"
			redirect_to :action => "index"	
		end
	end
	def customer
		links_per_page = 10  
  
		conditions = ["name LIKE ? or description Like ?", "%#{params[:query]}%","%#{params[:query]}%"] unless params[:query].nil?   
		@total = FavUrl.count(:conditions => conditions)   
		@links_pages, @link_list = paginate :fav_urls, :conditions => conditions, :per_page => links_per_page   
  
		if request.xml_http_request?   
			render :partial => "links_list", :layout => false   
		end   
		
	end
	
	def edit
		@links = FavUrl.paginate :page => params[:page], :per_page => 10
	end
	def link_form
		@link=nil
		if (params.key?(:id)) && !params[:id].nil?
			id=params[:id]
			@link=FavUrl.find(id)
		end
		if @link.nil?
			@link=FavUrl.new()
		end
    end
  def link_save
    @link_id=params[:id]
    if (@link_id.nil?)
      @link=FavUrl.new()
    else
      @link=FavUrl.find(@link_id)
      @link=FavUrl.find(@link_id)
    end

    if @link.update_attributes(params[:link])
	  redirect_to :action => "edit"
    else
      flash[:notice]="error"
      render :action=> "link_form" 
    end		
  end
  def link_delete
    id=params[:id]
    link=FavUrl.find(id)
    name=link.name

    if( FavUrl.delete(id))
      flash[:notice]="link #{name} has been deleted."
    else
	  flash[:error]="detele failed"
	end
    redirect_to :action => "customer"
  end
end