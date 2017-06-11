json.array!(@output_files) do |output_file|
  json.extract! output_file, :id, :file_path, :project_id, :name
  json.url output_file_url(output_file, format: :json)
end
