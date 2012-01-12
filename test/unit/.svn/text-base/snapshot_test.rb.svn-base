require File.dirname(__FILE__) + '/../test_helper'

class SnapshotTest < ActiveSupport::TestCase
  fixtures :snapshots
  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_get_sessions
    sessions=Snapshot.get_sessions()
    assert_equal  10,sessions.length
    assert_equal 15,sessions[0][:snap_count]
    assert_equal 11,sessions[1][:snap_count]
    assert_equal 2,sessions[2][:snap_count]
    puts sessions.inspect
  end
end
