class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, 
         :trackable, :validatable

  field :first_name, :type => String
  field :last_name,  :type => String
  field :superadmin, :type => Boolean, :default => false

  validates_presence_of :first_name, :last_name

  def full_name
    [first_name, last_name].join(" ")
  end 

end
