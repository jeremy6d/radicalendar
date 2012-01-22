class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  module Types
    ALL = [ SPECIAL_EVENT = "Special Event",
            WORKGROUP_EVENT = "Workgroup Event",
            UNOFFICIAL_EVENT = "Unofficial Event" ]
  end

  module Status
    ALL = [ APPROVED = "Approved",
            DENIED = "Denied",
            PENDING = "Pending" ]
  end

  field :name, :type => String
  field :location, :type => String
  field :start_datetime, :type => String
  field :end_datetime, :type => String
  field :ga_consensus_date, :type => String
  field :description, :type => String
  field :contact_name, :type => String
  field :contact_email, :type => String
  field :contact_phone, :type => String
  field :facebook_id, :type => String
  field :google_id, :type => String
  field :twitter_id, :type => String
  field :status, :type => String, :default => Event::Status::PENDING
  field :approved_at, :type => Time
  field :event_type, :type => String, :default => Event::Types::UNOFFICIAL_EVENT
  field :workgroup_name, :type => String

  attr_protected :approved_at

  belongs_to :approver, :class_name => "User"

  validates_presence_of :name, :location, :start_datetime, :end_datetime,
                        :description, :contact_name, :contact_email, 
                        :contact_phone, :status, :event_type

  validates_presence_of :ga_consensus_date, :if => Proc.new { |e| e.special_event? },
                                            :message => "is a required field for special events"
  
  validates_presence_of :workgroup_name, :if => Proc.new { |e| e.workgroup_event? },
                                         :message => "is a required field for workgroup events"
  
  default_scope asc(:start_datetime)

  alias_method :title, :name

  def ga_consensed?
    !ga_consensus_date.blank?
  end

  def official?
    event_type != Types::UNOFFICIAL_EVENT
  end

  Event::Status::ALL.each do |status_word|
    symbol = status_word.underscore.downcase.to_sym
    scope symbol, where(:status => status_word)
    define_method "#{symbol}?".to_sym do
      status == status_word
    end
  end

  Event::Types::ALL.each do |type_word|
    symbol = type_word.gsub(" ", "_").downcase.to_sym
    scope symbol, where(:event_type => type_word)
    define_method "#{symbol}?".to_sym do
      event_type == type_word
    end
  end


  def full_description
    contact_clause = 
    [ description, 
      "Contact #{contact_name} at #{contact_email} or #{contact_phone} for more information.",
      "(Approved via events.occupyrva.org by #{approver.try(:full_name) || 'an unknown Media workgroup member'})" ].join("\n\n")
  end

  def approve! user
    write_attribute :approver_id, user.id
    write_attribute :status, Event::Status::APPROVED
    write_attribute :approved_at, Time.now

    if Rails.env.production? && !ENV['DEBUG']
      post_to_google_calendar!

      if official?
        post_to_facebook! 
        post_to_twitter!
        #kickoff_email_alert!
      end
    end

    save!
  end

  def dismiss! user
    write_attribute :approver_id, user.id
    write_attribute :status, Event::Status::DENIED
  end

private
  def post_to_facebook!
    user = FbGraph::User.me OrvaEvents::Config.facebook.app_token
    page = user.accounts.find { |a| a.name == "Occupy Richmond" }
    event = page.event! :name => name,
                :description => full_description,
                :start_time => time_obj_for(start_datetime),
                :end_time => time_obj_for(end_datetime),
                :location => location
    write_attribute :facebook_id, event.identifier
  end

  def post_to_google_calendar!
    title = if official? 
      OrvaEvents::Config.google.official_calendar_title
    else  
      OrvaEvents::Config.google.unofficial_calendar_title
    end

    service = GCal4Ruby::Service.new
    service.authenticate OrvaEvents::Config.google.username, 
                         OrvaEvents::Config.google.password
    calendar = GCal4Ruby::Calendar.find(service, title).first
    
    event = GCal4Ruby::Event.new service
    event.calendar = calendar
    event.title = name
    event.start_time = time_obj_for(start_datetime)
    event.end_time = time_obj_for(end_datetime)
    event.where = location
    event.content = full_description
    
    event.save
    
    write_attribute :google_id, event.id
  end

  def post_to_twitter!
    result = Twitter.update "New event: #{name} http://facebook.com/#{facebook_id}"
    write_attribute :twitter_id, result.id.to_s
  end

  def kickoff_email_alert!

  end

  def just_approved?
    approved? && approved_at.blank?
  end

  def time_obj_for string
    date, time, ampm = string.split(" ")
    mo, day, yr = date.split("/").map(&:to_i)
    hr, min = time.split(":").map(&:to_i)
    hr = hr + 12 if ampm == "pm"
    
    Time::local yr, mo, day, hr, min
  end
end
