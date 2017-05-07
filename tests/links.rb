require "net/http"

# monkey patch Hash so we can iterate on keys, move this later... when I find out how globals and modules work better
class Hash
  def hmap(&block)
    Hash[se lf.map {|k, v| block.call(k,v) }]
  end
end

class Links
  def initialize(html_links)
    @likely_links = {}

    def url_exist?(url_string)

      # if url_string[-1] != '/'
      #   url_string = url_string.concat "/"


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

    html_links.css('a').map  do | link |
      search_for_link link['href']
    end

    @likely_links.each do |k,v|
      #   k.to_sym, v
      puts url_exist? k
    end

  end
end
