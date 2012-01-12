class LivetraceController < ApplicationController

  def index
    if User.exists?(current_user.id)
      user = User.find(current_user.id)
      @remote_ip=request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
      user.update_attribute(:live_ip,@remote_ip)
    end
  end
end
