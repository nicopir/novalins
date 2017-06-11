class Message < ActiveRecord::Base
	belongs_to :project
	belongs_to :sender, :class_name => 'User'
	belongs_to :receiver, :class_name => 'User'

	validates :subject, :body, :project_id, presence: true
end
