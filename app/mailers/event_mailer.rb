class EventMailer < ActionMailer::Base
  default from: "notifications@events.occupyrva.org"
  
  def status_change_email event
    @title = event.name
    @status = event.status
    mail(:to => event.contact_email,
         :subject => "Occupy Richmond Events: Update to your event")
  end 

  def new_event_email event
    @event = event
    mail :to => User.all.map(&:email),
         :subject => "New ORVA Event: #{event.name}"
  end
end
