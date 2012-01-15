class Devise::InvitationsController < ApplicationController
  skip_before_filter :require_no_authentication, :only => [:edit, :update]
  before_filter :only_superadmins_allowed, :only => [:new]
end