require 'net/http'
require 'nokogiri'
require './tests/links'

# intial request
url = URI.parse('http://bonzai-intranet.com/')
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}

# response codes & methods
responseCodes = {'404' => 'The page was not found.', '200' => 'The page was found.'}

define_method('404') do
end

define_method('200') do
  # write the file to disk
  open('.tmp/myfile.out', 'w') { |f|
    f.puts res.body
  }
  doc = Nokogiri::HTML(open('.tmp/myfile.out'))
  puts "-------------------"
  puts "STARTING WEB CRAWL"
  puts "-------------------"
  puts "Searching #{url} for stuffz.."
  puts "Document is of class #{doc.class}"
  puts "Page Title: #{doc.css('title')[0].text}"
  puts doc.css("h1")
  Links.new doc.css("a")
end

responseCodes.each do |key, thing|
  # print message
  if res.code === key
    self.send(key)
    puts thing
  end
end


