json.array!(@companies) do |company|
  json.extract! company, :id, :name, :description, :website, :logo, :billing_name, :vat_number, :street, :city, :state, :postal_code, :country
  json.url company_url(company, format: :json)
end
