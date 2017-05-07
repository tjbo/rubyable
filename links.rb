require "net/http"

class Links
  def initialize(links, uri)
    @maybe_links = {}
    @confirmed_links = {}

    # checks the url to see if exists, by sending a request
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

    # we need only absolute links
    links.each do |k,v|
      if k =~ /\Ahttps?/
        # set as hash to remove duplicates
        @maybe_links[k] = true
      else
        # this can result in double backslash, probably need better utility methods, but for now...
        if k[0] == "/"
          k[0] = ""
        end
        @maybe_links[k.prepend(uri)] = true
      end
    end

    @maybe_links.each do |k,v|
      if url_exist? k
        @confirmed_links[k] = true
      end
    end

    def get_links
      @confirmed_links
    end
  end
end
