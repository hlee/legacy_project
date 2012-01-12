class User < ActiveRecord::Base
  acts_as_user
  acts_as_encrypts_password

  before_destroy :check_user_admin
  
  validates_length_of :password, :minimum => 8, :allow_nil => false
  validates_uniqueness_of :email
  validates_format_of     :email,
                          :with => /((\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)|(\A([0-9]|[a-z]|[A-Z]|[_]|[\-])+\z))/i

  def check_user_admin
    user_admin_role = Role.find_by_display_name("User Admin")
    if self.has_role?(user_admin_role.identifier)
      unless User.find(:all).find_all{|user| user.has_role?(user_admin_role.identifier)}.length >= 2
        # The user we are deleting is the only admin user
        # do not allow the user to be deleted
        errors.add_to_base("Unable to delete last user with user_admin role")
        return false
      end
    end
  end
end
