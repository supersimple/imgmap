class LinkWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3
  
  def perform(link_id)
    link = Link.find link_id
    begin
      doc = Nokogiri::HTML(open(link.url, :allow_redirections => :all))
    rescue OpenURI::HTTPError
      link.update_attribute(:complete, true)
      return
    end
  
    imgs = []
    doc.xpath("//img").each do |img| #this will look for img tags, not any background images
      if link.is_correct_filetype?(img['src']) #only save gif, jpg, and png
        imgs << link.to_absolute_path(img['src'])
      end
    end
    link.update_attribute(:images, imgs)
    link.update_attribute(:complete, true)
end
end