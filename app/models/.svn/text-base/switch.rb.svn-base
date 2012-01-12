class Switch < ActiveRecord::Base
  validates_uniqueness_of :switch_name, :scope => :analyzer_id
  validates_uniqueness_of :address, :scope => :analyzer_id
  validates_length_of :switch_name, :minimum => 1
  validates_inclusion_of :address, :in=>1..99, :message => "must be between 1 and 99"
  validates_format_of     :switch_name,
                          :with => /\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/
  belongs_to :analyzer
  has_many :switch_ports, :dependent => :destroy
  has_many :ingress_ports, :class_name => "SwitchPort", :conditions => "purpose = #{SwitchPort::RETURN_PATH}"
  has_many :performance_ports, :class_name => "SwitchPort", :conditions => "purpose = #{SwitchPort::FORWARD_PATH}"
  def is_master?()
    return master_switch_flag
  end
  def validate
    if master_switch_flag
      errors.add(address, "Master switches must have an address of 1") unless address.eql?(1)
      return false
    end
  end
  def short_switch_name
    if switch_name.length < 13
      return switch_name
    else
      return "..." + switch_name.slice(-10,10)
    end
  end
end
