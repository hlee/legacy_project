class SfTestChannel < ActiveRecord::Base
  belongs_to :sf_channel
  belongs_to :sf_test_plan
  has_many :sites
  validates_uniqueness_of :sf_channel_id, :scope => :sf_test_plan_id

  def <=>(other)
    self.sf_channel["channel_number"].to_i <=> other.sf_channel["channel_number"].to_i
  end
end
