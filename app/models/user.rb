class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :company

  has_many :project_managed, :class_name => 'Project', :foreign_key => 'project_manager_id'
  has_many :project_owned, :class_name => 'Project', :foreign_key => 'project_owner_id', :dependent => :destroy

  has_many :message_sent, :class_name => 'Message', :foreign_key => 'sender_id'
  has_many :message_received, :class_name => 'Message', :foreign_key => 'receiver_id'

  validates :firstname, :lastname, :address, :location, :department, presence: true
  validates :phone, :mobile, numericality: { only_integer: true }, presence: true
end
