require "net/http"

class Links
  def initialize(links, uri)
    @maybe_links = {}
    @confirmed_links = {}

    # checks the url to see if exists, by sending a request
    def url_exist?(url_string)
      encoded_url = URI.encode(url_string)
      url = URI.parse(encoded_url)
      req = Net::HTTP.new(url.host, url.port)
      req.use_ssl = (url.scheme == 'https')
      path = url.path if url.path

      # these if statements are dodgy to me, needs better test and writing utilities for URIs
      if path[0] == nil
        path.prepend("/")
      end

      if path == nil || req == nil
        return false
      end

      # the script breaks here if the resquest fails, hence the resuce
      begin
        res = req.request_head(path)
      rescue
        return false

      end

      if res.kind_of?(Net::HTTPRedirection)
        url_exist?(res['location']) # Go after any redirect and make sure you can access the redirected URL
      else
        ! %W(4 5).include?(res.code[0]) # Not from 4xx or 5xx families
      end
    rescue Errno::ENOENT
      false #false if can't find the server
    end

    # we need only absolute links, and probably need a better way to serach for them, but for now...
    links.each do |k,v|
      if k =~ /\Ahttps?/
        # set as hash to remove duplicates
        @maybe_links[k] = true
      elsif k =~ /\Awww?/
        @maybe_links[k.prepend("http://")] = true
      else
        # this fixes double backslash, probably need better utility methods, but for now...
        if k && k[0] == "/"
          k[0] = ""
        end
        if k
          # "fixes" relative links
          @maybe_links[k.prepend(uri)] = true
        end
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
