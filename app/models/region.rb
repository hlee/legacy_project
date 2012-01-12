class Region < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_uniqueness_of :ip
  validates_presence_of   :name,
                          :message=>"Please input a name to region."
  validates_format_of     :name,
                          :with =>/\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/i
  validates_format_of     :ip,
                          :with => /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])$/,
                          :message=>"Please input a right format of ip address."

end
