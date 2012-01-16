class User
  include Mongoid::Document

  devise :invitable, :database_authenticatable, :recoverable, :rememberable, 
         :trackable, :validatable

  field :first_name, :type => String
  field :last_name,  :type => String
  field :superadmin, :type => Boolean, :default => false

  has_many :approved_events, :class_name => "Event", 
                             :foreign_key => "approver_id"

  validates_presence_of :first_name, :last_name

  def full_name
    [first_name, last_name].join(" ")
  end 

end
