require 'net/http'

uri = URI('https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/analyze?visualFeatures=Description,Tags')
#uri.query = URI.encode_www_form({
#
#    'language' => 'unk',
#    'detectOrientation ' => 'true'
#})

request = Net::HTTP::Post.new(uri.request_uri)

request['Content-Type'] = 'application/octet-stream'

request['Ocp-Apim-Subscription-Key'] = ARGV[0]

request.body = File.binread(ARGV[1])

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
end

puts response.body
#puts request.body
#puts response
