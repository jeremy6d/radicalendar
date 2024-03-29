class EventsController < ApplicationController
	inherit_resources
  custom_actions :resource => [ :approve, :dismiss ]
  before_filter :authenticate_user!, :only => [ :edit, :update ]

  def index
    @status = params[:status] if Event::Status::ALL.include?(params[:status])
    @status ||= Event::Status::PENDING
    @events = collection.send(@status.downcase.to_sym)
  end

  def approve
    @event = collection.find params[:id]
    @event.approve! current_user
    EventMailer.status_change_email(@event).deliver!
    redirect_to event_path(@event), :notice => "Event was approved."
  end

  def dismiss
    @event = collection.find params[:id]
    @event.dismiss! current_user
    EventMailer.status_change_email(@event).deliver!
    redirect_to event_path(@event), :notice => "Event was dismissed."
  end
  
  def create
    create! do |success, failure|
      success.html do
        EventMailer.new_event_email(@event).deliver!
        redirect_to root_path, :notice => "Your event was submitted and the Media workgroup has been notified."
      end
    end
  end

protected
  def collection
    @events ||= Event.all
  end
end
