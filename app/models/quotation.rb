class Quotation < ActiveRecord::Base
	mount_uploader :file_path, FileUploader
	belongs_to :project
	belongs_to :currency
end
