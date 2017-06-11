json.array!(@input_files) do |input_file|
  json.extract! input_file, :id, :file_path, :project_id
  json.url input_file_url(input_file, format: :json)
end
