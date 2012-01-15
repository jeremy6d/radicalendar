class EventsController < ApplicationController
	inherit_resources
  before_filter :authenticate_user!, :only => [ :edit, :update ]

protected
  def collection
    @events ||= Event.all
  end
end
