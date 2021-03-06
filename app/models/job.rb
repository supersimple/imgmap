class Job < ActiveRecord::Base
  has_many :links
  
  # THESE SHOULD BE MOVED INTO AN ASYNC CALL IN ORDER TO GET GOOD DATA ON THE PROGRESS PAGE
  after_save :generate_uris
  
  #method will create a new Job and Uri(s)
  def self.generate(params)
    job = Job.new(params: params)
    job.save
    job
  end
  
  def inprogress
    links.inprogress.count
  end
  
  def completed
    links.completed.count
  end
  
  private
  
  def generate_uris
    urls = JSON.parse(self.params)
    urls.each{ |url| link = self.links.new(url: url); link.save; link.parse_for_links; }
  end
  
  def generate_images
    links.each{ |link| link.parse_for_images }
  end
  
end
