class Company < ActiveRecord::Base
	has_many :users
	has_many :project_owned, through: :users

	mount_uploader :logo, PictureUploader

	validates :name, :description, :website, :billing_name, :street, :city, :state, :country, presence: true
	validates :vat_number, :postal_code, numericality: { only_integer: true }, presence: true
end
