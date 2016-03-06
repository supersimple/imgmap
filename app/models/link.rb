class Link < ActiveRecord::Base
  require 'open-uri'
  
  belongs_to :job
    
  scope :completed, -> { where(complete: true) }
  scope :inprogress, -> { where(complete: false) }
  
  def parse_for_links
    @job_id = job_id
    parse_dom #this will grab all the links from the main URL and make a new URI record for each
  end
  
  def parse_for_images
    search_for_images
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
  
  def search_for_images
    begin
      doc = Nokogiri::HTML(open(url, :allow_redirections => :all))
    rescue OpenURI::HTTPError
      return
    end
    
    imgs = []
    doc.xpath("//img").each do |img| #this will look for img tags, not any background images
      if is_correct_filetype?(img['src']) #only save gif, jpg, and png
        imgs << to_absolute_path(img['src'])
      end
    end
    update_attribute(:images, imgs)
    update_attribute(:complete, true)
  end
  
  def is_correct_filetype?(file)
    return false if file.nil?
    ['.gif', '.jpg', '.png'].include? File.extname(URI.parse(file).path)
  end
  
  private
  
  def link_valid?(link)
    return false if link.nil?
    #ignore mailto: and anchors. check if link matches an expected uri pattern
    !link.gsub(url,'').start_with?('#','mailto:') && (link =~ /\A#{URI::regexp}\z/) == 0
  end
  
  def to_absolute_path(link)
    #if the URL is realtive, prepend it with the obj.uri
    URI.join(url, link).to_s
  end
  
end
