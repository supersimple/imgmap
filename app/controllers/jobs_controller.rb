class JobsController < ApplicationController
  before_action :find_job, only: [:status, :results]
  
  def create
    #params[:urls] will contain the list of URLs to parse
    @job = Job.generate(params[:urls])
    render json: { id: @job.id }, status: 202
  end
  
  def status
    render json: {id: @job.id, status: { completed: @job.completed, inprogress: @job.inprogress}}     
  end
  
  def results
    render json: {id: @job.id, results: {}}
  end
  
  private
  
  def find_job
    begin
      @job = Job.find params[:job_id]     
    rescue ActiveRecord::RecordNotFound
      render json: {'Error': 'Job not found'}.to_json , status: 404
    end
  end
end
