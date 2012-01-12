module MainHelper
	def pagination_links_remote(paginator)
	  page_options = {:window_size => 1}
	  pagination_links_each(paginator, page_options) do |n|
	    options = {
	      :url => {:action => 'list', :params => params.merge({:page => n})},
	      :update => 'table',
	      :before => "Element.show('spinner')",
	      :success => "Element.hide('spinner')"
	    }
	    html_options = {:href => url_for(:action => 'list', :params => params.merge({:page => n}))}
	    link_to_remote(n.to_s, options, html_options)
	  end
	end
	def sort_td_class_helper(param)
	  result = 'class="sortup"' if params[:sort] == param
	  result = 'class="sortdown"' if params[:sort] == param + "_reverse"
	  return result
	end
	def sort_link_helper(text, param)
	  key = param
	  key += "_reverse" if params[:sort] == param
	  options = {
	      :url => {:action => 'list', :params => params.merge({:sort => key, :page => nil})},
	      :update => 'table',
	      :before => "Element.show('spinner')",
	      :success => "Element.hide('spinner')"
	  }
	  html_options = {
	    :title => "Sort by this field",
	    :href => url_for(:action => 'list', :params => params.merge({:sort => key, :page => nil}))
	  }
	  link_to_remote(text, options, html_options)
	end
    def show_analyzer(site_name)
        site_id=Site.find_by_name(site_name)
        s_port=SwitchPort.find_by_site_id(site_id)
        if (s_port.nil?)
          analyzer=Analyzer.find_by_site_id(site_id)
        else
          switch=Switch.find_by_id(s_port[:switch_id])
          analyzer=Analyzer.find_by_id(switch[:analyzer_id])
        end
        if (analyzer.nil?)
          return "UNKNOWN"
        else
          return analyzer[:name]
        end
    end
    def show_port(site_name)
        swp=SwitchPort.find_by_site_id(Site.find_by_name(site_name))
        if (swp.nil?)
          return 'NONE'
        else
          return swp.name
        end
    end

end
