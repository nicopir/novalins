json.array!(@messages) do |message|
  json.extract! message, :id, :subject, :body, :read, :project_id, :sender_id, :receiver_id
  json.url message_url(message, format: :json)
end
