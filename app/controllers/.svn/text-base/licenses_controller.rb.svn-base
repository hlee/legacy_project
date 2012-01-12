class LicensesController < ApplicationController
  def index
    @license = License.new('license.txt.asc')

    respond_to do |format|
      format.html # index.html.erb
    end
  end
  def upload
    @license = License.new('license.txt.asc')
    if params["license_file"].eql?('')
      flash[:error] = "Please provide a filename to upload"
      redirect_to :action=> 'index'
      return false
    end
    if params.key?("license_file")
      File.open('license.txt.asc', "w") {|f|
        f.write(params["license_file"].read)
      }
      @license.filename = 'license.txt.asc'
      if @license.valid?
        flash[:notice] = "New License data listed below"
      else
        flash[:error] = "There was a problem parsing your license file"
      end
      redirect_to :action=> 'index'
    end
  end
end
