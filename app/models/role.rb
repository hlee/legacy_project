class Role < ActiveRecord::Base
  acts_as_role

  def <=>(other)
    self.identifier <=> other.identifier
  end
end
