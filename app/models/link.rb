class Link < ActiveRecord::Base
  require 'open-uri'
  
  belongs_to :job
    
  scope :completed, -> { where(complete: true) }
  scope :inprogress, -> { where(complete: false) }
  
  def parse_for_links
    @job_id = job_id
    parse_dom #this will grab all the links from the main URL and make a new URI record for each
    #now that we have all the URLs for this job, start collecting all the images
    search_for_images
    update_attribute(:complete, true)
  end
  
  private
  
  def parse_dom
    doc = Nokogiri::HTML(open(url))
    doc.xpath("//a").each do |a| #create a new record for each link found
      if link_valid?(a['href'])
        self.class.new(url: to_absolute_path(a['href']), job_id: @job_id).save
      end
    end
  end
  
  def search_for_images
    doc = Nokogiri::HTML(open(url))
    imgs = []
    doc.xpath("//img").each do |img| #this will look for img tags, not any background images
      if is_correct_filetype?(img['src']) #only save gif, jpg, and png
        imgs << to_absolute_path(img['src'])
      end
    end
    update_attribute(:images, imgs)
  end
  
  def is_correct_filetype?(file)
    ['.gif', '.jpg', '.png'].include? File.extname(URI.parse(file).path)
  end
  
  private
  
  def link_valid?(link)
    #ignore mailto: and anchors. check if link matches an expected uri pattern
    !link.gsub(url,'').start_with?('#','mailto:') && (link =~ /\A#{URI::regexp}\z/) == 0
  end
  
  def to_absolute_path(link)
    #if the URL is realtive, prepend it with the obj.uri
    URI.join(url, link).to_s
  end
  
end
