require "net/http"
require "nokogiri"
require "./links"
require "./target"
url = "http://bonzai-intranet.com/"

@targets = {}

def maybe_add_target uri, fetched, filename, parentUri
  # if the target doesn't exist yet, add it
  if !@targets[uri]

    new_target = Target.new(uri, fetched, filename, parentUri)
    @targets[uri] = new_target

    # only spider if it's local to url
    if new_target.is_local
      get_url new_target.uri
    end
  end
end

def print_header
  puts "-------------------"
  puts "STARTING WEB CRAWL"
  puts "-------------------"
end

# each link that we fetch, will return a page with potential links to other pages
# which we should recursivily check for links
def maybe_child_targets  uris, uri
  # this could be more efficient by trackign whihc uris have already been fetched
  maybe_new_targets = Links.new(uris, uri)
  maybe_new_targets.get_links.each do |k,v|
    # add children of target
    maybe_add_target k, false, "", uri
  end
end

def get_url uri
  # response codes & methods
  responseCodes = {'404' => 'The page was not found.', '200' => 'The page was found.'}

  # rewrite file name so that it doesn't have any weird characters
  puts new_file_name = uri.gsub(/[\.\/:-]/, "_")

  # a network request that needs better error checking
  url = URI.parse(uri)
  req = Net::HTTP::Get.new(url.to_s)
  res = Net::HTTP.start(url.host, url.port) {|http|
    http.request(req)
  }

  define_method('404') do
    print_header
    puts "There was a 404 error for #{url}"
  end


  # if the request is successful, do some stuff
  define_method('200') do
    print_header
    #write the file to disk
    open(".tmp/#{new_file_name}", "w") { |f|
      f.puts res.body
    }
    # ftech an html tree
    doc = Nokogiri::HTML(res.body)
    puts "Searching #{url} for stuffz.."
    puts "Document is of class #{doc.class}"
    puts "Page Title: #{doc.css('title')[0].text}"
    puts doc.css("h1")

    # get the child links from any anchor links in the tree
    links = doc.css("a").css('a').map  do | link |
      link['href']
    end

    maybe_add_target uri, true, new_file_name, uri
    maybe_child_targets(links, uri)
  end

  # maybe change this, unless we need better error code checking
  responseCodes.each do |key, thing|
    # print message
    if res.code === key
      self.send(key)
      puts thing
    end
  end
end

get_url(url)

