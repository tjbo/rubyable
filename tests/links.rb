require "net/http"

class Links
  def initialize(html_links)
    # puts html_links
    @likely_links = {}
    @actual_links = {}

    def url_exist?(url_string)
      url = URI.parse(url_string)
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl = (url.scheme == 'https')
      path = url.path if url.path

      if path[0] == nil
        path.prepend("/")
      end

      res = req.request_head(path || '/')

      if res.kind_of?(Net::HTTPRedirection)
        url_exist?(res['location']) # Go after any redirect and make sure you can access the redirected URL
      else
        ! %W(4 5).include?(res.code[0]) # Not from 4xx or 5xx families
      end
    rescue Errno::ENOENT
      false #false if can't find the server
    end

    def search_for_link possible_link
      if possible_link =~ /\Ahttps?/
        # set as hash to remove duplicates
        @likely_links[possible_link] = true
      end
    end

    # get the link from the anchor tag
    html_links.css('a').map  do | link |
      search_for_link link['href']
    end

    # puts @likely_links


    @likely_links.each do |k,v|
      #   k.to_sym, v
      if url_exist? k
        @actual_links[k] = true
      end
    end

    # just for printing
    # @actual_links.each do |k,v|
    #   puts @actual_links[k]
    # end


  end
end
