require File.dirname(__FILE__) + '/../test_helper'

class AlarmMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end

  def test_true
    assert true
  end

  def disabled_test_ingress_alarm
    @expected.subject = 'AlarmMailer#ingress_alarm'
    @expected.body    = read_fixture('ingress_alarm')
    @expected.date    = Time.now

    assert_equal @expected.encoded, AlarmMailer.create_ingress_alarm(@expected.date).encoded
  end

  def disabled_test_performance_alarm
    @expected.subject = 'AlarmMailer#performance_alarm'
    @expected.body    = read_fixture('performance_alarm')
    @expected.date    = Time.now

    assert_equal @expected.encoded, AlarmMailer.create_performance_alarm(@expected.date).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/alarm_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
