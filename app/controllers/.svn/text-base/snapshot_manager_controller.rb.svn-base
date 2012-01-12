class SnapshotManagerController < ApplicationController
  def index
    @session_list=Snapshot.get_sessions(params["start_date"], params["stop_date"],params["source"],params["site_name"])
    page=(params[:page] || 1).to_i
    offset=(page-1)*20
    @item_pages=Paginator.new(self, @session_list.length,20,page)
    @session_list=@session_list[offset..(offset+19)]
    if @session_list.nil?
      @session_list=[]
    end
  end
  def session_browse
     @snapshots=[]
     if (params.key?('session'))
       @snapshots=Snapshot.find(:all, :conditions=>{:session=>params['session']})
     end
     
     render  :layout => 'snapshot_session'
  end
end
