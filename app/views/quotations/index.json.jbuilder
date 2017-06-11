json.array!(@quotations) do |quotation|
  json.extract! quotation, :id, :file_path, :project_id, :name, :cost, :deadline
  json.url quotation_url(quotation, format: :json)
end
