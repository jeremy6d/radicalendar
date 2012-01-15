class UsersController < ApplicationController
  inherit_resources
  before_filter :authenticate_user!
  before_filter :only_superadmins_allowed
end
