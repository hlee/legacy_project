class AlarmMailer < ActionMailer::Base
  #SMTP_SERVER=17
  #SMTP_PORT=18
  #SMTP_USERNAME=20
  #SMTP_PASSWORD=21
  #SENDER_ADDRESS=22
  #REPLY_ADDRESS=23

  def ingress_alarm(alarm = "unknown", to = "", sent_at = Time.now)
    smtp_setup()
    if to.eql?('')
      return
    end
    @subject    = "An Ingress alarm occurred on #{alarm.site.name}"
    @body       = {:alarm => alarm}
    @recipients = to
    @from       = ConfigParam.get_value(ConfigParam::SENDER_ADDRESS)
    @sent_on    = sent_at
    @headers    = {'Reply-To'=>ConfigParam.get_value(ConfigParam::REPLY_ADDRESS)}
  end

  def performance_alarm(alarm = "unknown", to = "", sent_at = Time.now)
    smtp_setup()
    if to.eql?('')
      return
    end
    @subject    = "A Performance alarm occurred on #{alarm.site.name}"
    @body       = {:alarm => alarm}
    @recipients = to
    @from       = ConfigParam.get_value(ConfigParam::SENDER_ADDRESS)
    @sent_on    = sent_at
    @headers    = {'Reply-To'=>ConfigParam.get_value(ConfigParam::REPLY_ADDRESS)}
  end
  private
  def smtp_setup
    server=ConfigParam.get_value(ConfigParam::SMTP_SERVER).strip;
    port=ConfigParam.get_value(ConfigParam::SMTP_PORT);
    username=ConfigParam.get_value(ConfigParam::SMTP_USERNAME).strip;
    password=ConfigParam.get_value(ConfigParam::SMTP_PASSWORD).strip;
    ActionMailer::Base.smtp_settings={:address =>server, :port => port}
    if (username.length > 0)
      ActionMailer::Base.smtp_settings[:user_name]= username
      ActionMailer::Base.smtp_settings[:password]= password
      ActionMailer::Base.smtp_settings[:authentication]= :login
    end
  end
end
