require "net/http"
require "nokogiri"
require "./links"
require "./target"
uri = "http://bonzai-intranet.com/"
# uri = "https://howtotuneaguitar.org/"
# a network request that needs better error checking
url = URI.parse(uri)
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}

@targets = {}

def add_target uri, fetched
  if !@targets[uri]
    new_target = Target.new(uri, fetched)
    @targets[uri] = new_target
  else
    puts "not a target"
  end
end

# response codes & methods
responseCodes = {'404' => 'The page was not found.', '200' => 'The page was found.'}

def print_header
  puts "-------------------"
  puts "STARTING WEB CRAWL"
  puts "-------------------"
end

define_method('404') do
  print_header
  puts "There was a 404 error for #{url}"
end

def process_target  uris, uri
  maybe_new_targets = Links.new(uris, uri)
  maybe_new_targets.get_links.each do |k,v|
    add_target k, false
  end
end

# if the request is successful, do some stuff
define_method('200') do
  # write the file to disk
  open('.tmp/myfile.out', 'w') { |f|
    f.puts res.body
  }
  doc = Nokogiri::HTML(open('.tmp/myfile.out'))
  print_header
  puts "Searching #{url} for stuffz.."
  puts "Document is of class #{doc.class}"
  puts "Page Title: #{doc.css('title')[0].text}"
  puts doc.css("h1")

  # get the link from the anchor tag
  links = doc.css("a").css('a').map  do | link |
    link['href']
  end
  process_target(links, uri)
end

# maybe change this, unless we need better error code checking
responseCodes.each do |key, thing|
  # print message
  if res.code === key
    self.send(key)
    puts thing
  end
end
