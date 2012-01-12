class UpstreamChannelsController < ApplicationController
  # GET /upstream_channels
  # GET /upstream_channels.xml
  #
  layout "network"
  def index
    @upstream_channels = UpstreamChannel.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @upstream_channels }
    end
  end

  # GET /upstream_channels/1
  # GET /upstream_channels/1.xml
  def show
    @upstream_channel = UpstreamChannel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @upstream_channel }
    end
  end

  # GET /upstream_channels/new
  # GET /upstream_channels/new.xml
  def new
    @upstream_channel = UpstreamChannel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @upstream_channel }
    end
  end

  # GET /upstream_channels/1/edit
  def edit
    @upstream_channel = UpstreamChannel.find(params[:id])
  end

  # POST /upstream_channels
  # POST /upstream_channels.xml
  def create
    @upstream_channel = UpstreamChannel.new(params[:upstream_channel])

    respond_to do |format|
      if @upstream_channel.save
        flash[:notice] = 'UpstreamChannel was successfully created.'
        format.html { redirect_to(upstream_channels_url) }
        format.xml  { render :xml => @upstream_channel, :status => :created, :location => @upstream_channel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @upstream_channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /upstream_channels/1
  # PUT /upstream_channels/1.xml
  def update
    @upstream_channel = UpstreamChannel.find(params[:id])

    respond_to do |format|
      if @upstream_channel.update_attributes(params[:upstream_channel])
        flash[:notice] = 'UpstreamChannel was successfully updated.'
        format.html { redirect_to(upstream_channels_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @upstream_channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /upstream_channels/1
  # DELETE /upstream_channels/1.xml
  def destroy
    @upstream_channel = UpstreamChannel.find(params[:id])
    @upstream_channel.destroy

    respond_to do |format|
      format.html { redirect_to(upstream_channels_url) }
      format.xml  { head :ok }
    end
  end
end
