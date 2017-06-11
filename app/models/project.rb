class Project < ActiveRecord::Base
	belongs_to :project_manager, :class_name => 'User'
	belongs_to :project_owner, :class_name => 'User'
	belongs_to :category
	belongs_to :currency
	belongs_to :company
	has_many :input_files, :dependent => :destroy
	has_many :quotations, :dependent => :destroy
	has_many :invoices, :dependent => :destroy
	has_many :output_files, :dependent => :destroy
	has_many :messages, :dependent => :destroy

	validates :title, :description, :category_id, presence: true
	validates :cost, numericality: { only_integer: true }, :allow_blank => true
	validates :urgency, presence: true, inclusion: { in: ["Low", "Middle", "High"]}
	def self.search(query)
		where("title like ?", "%#{query}%")
	end
end
