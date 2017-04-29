require 'net/http'
require 'nokogiri'

url = URI.parse('http://bonzai-intranet.com/adsfa')
req = Net::HTTP::Get.new(url.to_s)
res = Net::HTTP.start(url.host, url.port) {|http|
  http.request(req)
}

responseCodes = {'404' => 'The page was not found.', '200' => 'The page was found.'}

responseCodes.each do |key, thing|
    if res.code === key
        puts key, thing
    end
end


