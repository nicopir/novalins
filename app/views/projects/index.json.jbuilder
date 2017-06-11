json.array!(@projects) do |project|
  json.extract! project, :id, :title, :status, :description, :cost, :category, :urgency, :deadline, :starting, :instruction, :project_manager_id
  json.url project_url(project, format: :json)
end
