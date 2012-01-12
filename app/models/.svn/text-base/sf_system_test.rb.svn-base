class SfSystemTest < ActiveRecord::Base
  belongs_to :sf_test_plan
  has_many :measure, :class_name => "Measure",
    :finder_sql => 'SELECT * from measures where sf_meas_ident = #{test_type}'
  validates_numericality_of :min_value,:max_value,:allow_nil => 'true'
  
  def validate
      errors.add(:max_value,"should bigger than min_value") if !min_value.nil? && !max_value.nil? && min_value > max_value 
  end
end
