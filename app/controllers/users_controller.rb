class UsersController < ApplicationController
  inherit_resources
  before_filter :authenticate_user!
  before_filter :only_superadmins_allowed

protected
  def only_superadmins_allowed
    unless current_user.superadmin?
      redirect_to root_url, :alert => "You are not allowed to view that."
    end
  end
end
