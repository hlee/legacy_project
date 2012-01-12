module LicenseSystem
  def has_ingress?
    license = ConfigParam.get_value("License")
    return license.has_ingress?
  end
  def has_performance?
    license = ConfigParam.get_value("License")
    return license.has_performance?
  end
  def has_license?
    license = ConfigParam.get_value("License")
    return license.valid?
  end
  def has_laser_clipping?
    return true
  end
  def self.included(base)
    base.send :helper_method, :has_performance?, :has_ingress?, :has_license?, :has_laser_clipping?
  end
end
