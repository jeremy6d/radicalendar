class ApplicationController < ActionController::Base
  protect_from_forgery

protected
  def only_superadmins_allowed
    unless current_user.superadmin?
      redirect_to root_url, :alert => "You are not allowed to view that."
    end
  end
end
