Rails.application.routes.draw do
  post '/jobs' => 'jobs#create', defaults: { format: 'json' }
  get '/jobs/:job_id/status' => 'jobs#status', defaults: { format: 'json' }
  get '/jobs/:job_id/results' => 'jobs#results', defaults: { format: 'json' }
end
