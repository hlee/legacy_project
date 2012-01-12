class FavUrl < ActiveRecord::Base
  validates_uniqueness_of :name,:url
  validates_presence_of   :name,:url
  validates_length_of     :name, :within => 1..19,
                          :too_long =>"please enter at most %d character",  
                          :too_short=>"please enter at least %d character"
  validates_format_of     :name,
                          :with =>/\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/i
 # validates_format_of     :url,
                         # :with =>/\A([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]| )*([0-9]|[a-z]|[A-Z]|[_]|[\-]|[\/]|$)\z/i
  validates_format_of     :url,
                          :with =>/(^(javascript:|http:\/\/|https:\/\/)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)|^$|^about:blank$/ix  
 						 

end