class Link < ActiveRecord::Base
  require 'open-uri'
  
  belongs_to :job
  
  after_create :parse_for_images
    
  scope :completed, -> { where(complete: true) }
  scope :inprogress, -> { where(complete: false) }
  
  def parse_for_links
    @job_id = job_id
    parse_dom #this will grab all the links from the main URL and make a new URI record for each
  end
  
  def parse_for_images
    LinkWorker.perform_async(id)
  end
    
  def is_correct_filetype?(file)
    return false if file.nil?
    ['.gif', '.jpg', '.png'].include? File.extname(URI.parse(file).path)
  end
    
  def link_valid?(link)
    return false if link.nil?
    #ignore mailto: and anchors. check if link matches an expected uri pattern
    !link.gsub(url,'').start_with?('#','mailto:') && (link =~ /\A#{URI::regexp}\z/) == 0
  end
  
  def to_absolute_path(link)
    #if the URL is realtive, prepend it with the obj.uri
    URI.join(url, link).to_s
  end
  
  private
  
  def parse_dom
    doc = Nokogiri::HTML(open(url, :allow_redirections => :all))
    doc.xpath("//a").each do |a| #create a new record for each link found
      if link_valid?(a['href'])
        self.class.new(url: to_absolute_path(a['href']), job_id: @job_id).save
      end
    end
  end
  
end
