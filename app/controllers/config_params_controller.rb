class ConfigParamsController < ApplicationController
	in_place_edit_for :config_param, :val

  def index
    list
    render :action => 'list'
  end

  def smtp_settings
    @config_params = ConfigParam.find(:all, :conditions => ["category = 'SMTP'"])
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @config_params = ConfigParam.find(:all, :conditions => ["category != 'SMTP'"])
  end

  def show
    @config_param = ConfigParam.find(params[:id])
  end

  def edit
    @config_param = ConfigParam.find(params[:id])
  end

  def update
    @config_param = ConfigParam.find(params[:id])
    if @config_param.update_attributes(params[:config_param])
      flash[:notice] = 'ConfigParam was successfully updated.'
      if @config_param.category.eql?('SMTP')
        redirect_to :action => 'smtp_settings'
      else
        redirect_to :action => 'list'
      end
    else
      render :action => 'edit'
    end
  end
end
