require File.dirname(__FILE__) + '/../test_helper'

class SystemLogsTest < Test::Unit::TestCase
  fixtures :system_logs, :config_params

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_datalog_build
     result=SystemLog.log()
     assert result.nil?

     result=SystemLog.log("Hello")
     assert !result.nil?
     sys=SystemLog.find(result)
     assert_equal sys.short_descr,"Hello"
     assert_equal sys.descr,"Hello"

     result=SystemLog.log("Description","Long Description")
     sys=SystemLog.find(result)
     assert_equal sys.short_descr, "Description"
     assert_equal sys.descr, "Long Description"
     assert_equal sys.level, 128
     assert sys.analyzer_id.nil?

     result=SystemLog.log("Description","Long Description",SystemLog::WARNING)
     sys=SystemLog.find(result)
     assert_equal sys.short_descr, "Description"
     assert_equal sys.descr, "Long Description"
     assert_equal sys.level, SystemLog::WARNING
     assert sys.analyzer_id.nil?

     result=SystemLog.log("Description","Long Description",SystemLog::MESSAGE)
     sys=SystemLog.find(result)
     assert_equal sys.short_descr, "Description"
     assert_equal sys.descr, "Long Description"
     assert_equal sys.level, SystemLog::MESSAGE
     assert sys.analyzer_id.nil?

     result=SystemLog.log("Description","Long Description",SystemLog::ERROR)
     sys=SystemLog.find(result)
     assert_equal sys.short_descr, "Description"
     assert_equal sys.descr, "Long Description"
     assert_equal sys.level, SystemLog::ERROR
     assert sys.analyzer_id.nil?

     assert_raise(ActiveRecord::RecordNotFound) {SystemLog.log("Description","Long Description",SystemLog::ERROR,77)}

     anl=Analyzer.create()
     result=SystemLog.log("Description","Long Description",SystemLog::ERROR,anl.id)
     assert !result.nil?
  end
end
