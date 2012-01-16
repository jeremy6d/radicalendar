class EventsController < ApplicationController
	inherit_resources
  custom_actions :resource => [ :approve, :dismiss ]
  before_filter :authenticate_user!, :only => [ :edit, :update ]

  def approve
    @event = collection.find params[:event_id]
    @event.approve! current_user
    EventMailer.status_change_email(@event).deliver!
    redirect_to event_path(@event), :notice => "Event was approved."
  end

  def dismiss
    @event = collection.find params[:event_id]
    @event.dismiss! current_user
    EventMailer.status_change_email(@event).deliver!
    redirect_to event_path(@event), :notice => "Event was dismissed."
  end

protected
  def collection
    @events ||= Event.all
  end
end
