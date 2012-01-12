class ScheduledSource < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :switch_port
end
