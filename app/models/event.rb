class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  module Types
    ALL = [ SPECIAL_EVENT = "Special Event",
            WORKGROUP = "Workgroup",
            UNOFFICIAL = "Unofficial" ]
  end

  module Status
    ALL = [ APPROVED = "Approved",
            UNAPPROVED = "Unapproved",
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
  field :event_type, :type => String, :default => Event::Types::UNOFFICIAL

  validates_presence_of :name, :location, :start_datetime, :end_datetime,
                        :description, :contact_name, :contact_email, 
                        :contact_phone, :status, :event_type

  before_save :export!, :if => :just_approved?

  default_scope asc(:start_datetime)

  def ga_consensed?
    !ga_consensus_date.blank?
  end

  def official?
    event_type != Types::UNOFFICIAL
  end

  # %w(start end ga_consensed).each do |prefix|
  #   attr_name = "#{prefix}_datetime"
  #   method_name = "#{attr_name}="
  #   define_method method_name.to_sym do |datetime|
  #     debugger
  #     write_attribute attr_name, Time.parse(datetime)
  #   end
  # end

  Event::Status::ALL.each do |status_word|
    symbol = status_word.underscore.downcase.to_sym
    scope symbol, where(:status => status_word)
    define_method "#{symbol}?".to_sym do
      status == status_word
    end
  end

  def full_description
    contact_clause = "Contact #{contact_name} at #{contact_email} or #{contact_phone} for more information."
    [ description, contact_clause ].join("\n\n")
  end

private
  def export!
    post_to_google_calendar!

    if official?
      post_to_facebook! 
      post_to_twitter!
      kickoff_email_alert!
    end

    approved_at = Time.now
  end

  def post_to_facebook!
    app = FbGraph::Application.new Config.facebook.app_id
    token = app.get_access_token Config.facebook.app_secret
    page = FbGraph::Page.new(Config.facebook.page_id, :access_token => token).fetch
    event = page.event!
  end

  def post_to_google_calendar!
    title = if official? 
      Config.google.official_calendar_title
    else  
      Config.google.unofficial_calendar_title
    end

    service = GCal4Ruby::Service.new
    service.authenticate(Config.google.username, Config.google.password)
    calendar = GCal4Ruby::Calendar.find(service, title).first
    
    event = GCal4Ruby::Event.new service
    event.calendar = calendar
    event.title = name
    event.start_time = time_obj_for(start_datetime)
    event.end_time = time_obj_for(end_datetime)
    event.where = location
    event.content = full_description
    
    event.save
    debugger
    google_id = event.id
  end

  def post_to_twitter!
    Twitter.update "New event: #{}"
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
