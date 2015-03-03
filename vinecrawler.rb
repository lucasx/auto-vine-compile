require 'net/https'
require 'uri'

class VineCrawler
	def getPopularNow(quantity)
		jsonBody = self.class.getJSON(searchTerm, nResults)
		videoUrls = self.class.parseURLs(jsonBody)
		self.class.retrieveVideos(videoUrls)
	end

	def self.getJSON(searchTerm, nResults)
		puts "Requesting 10 videos..."
		# Todo: replace spaces with %20's
		#url = URI.parse('https://vine.co/api/posts/search/#{searchTerm}?size=#{nResults}')
		url = URI.parse('https://vine.co/api/posts/search/super%20bowl?size=10')
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE

		req = Net::HTTP::Get.new(url.request_uri)
		res = http.request(req)

		res.body
	end

	def self.parseURLs(jsonBody)
		puts "Parsing video URLs..."
		videoRegexMatches = jsonBody.scan(/\"videoUrl\": \"[^\"]*\"/)
		videoUrls = []

		videoRegexMatches.each do | match |
			videoUrls << match.split('"')[3]
		end

		videoUrls
	end

	def self.retrieveVideos(videoUrls)
		numVideo = 1

		puts "Requesting individual videos and streaming to file."
		videoUrls.each do | nextUrl |
			nextURI = URI.parse(nextUrl)
			http = Net::HTTP.new(nextURI.host, nextURI.port)

			req = Net::HTTP::Get.new(nextURI.request_uri)
			req["Content-Type"] = "video/mp4"

			res = http.request(req)

			open("#{numVideo}.mp4", "wb") do | file |
				file << res.body
			end

			numVideo = numVideo + 1
		end
	end
end


if __FILE__ == $0 #If we're using this file as the main executable, as opposed to importing it as a library or something
	crawler = VineCrawler.new
	crawler.getVideos("super%20bowl", 10)
end