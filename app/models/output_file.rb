class OutputFile < ActiveRecord::Base
	mount_uploader :file_path, FileUploader
	belongs_to :project

	validates :file_path, presence: true
end
