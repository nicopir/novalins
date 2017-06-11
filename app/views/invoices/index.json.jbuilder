json.array!(@invoices) do |invoice|
  json.extract! invoice, :id, :file_path, :project_id, :name
  json.url invoice_url(invoice, format: :json)
end
