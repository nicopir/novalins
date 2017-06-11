class Currency < ActiveRecord::Base
	has_many :projects
	has_many :quotations
end
