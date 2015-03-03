require 'rubygems'
require 'json'
require 'vinecrawler'

class VineKeeper
	MAX_VINES_IN_RECORD = 6000 # Max number of vines per daily JSON file

	def VineKeeper.updateMostPopular
		vr = self.getTodaysVineRecord
		populars = VineCrawler.getPopularNow 50
		
		populars.each do |vine|
			vr.updateVine(vine)
		end

		if vr.length > MAX_VINES_IN_RECORD
			vr.updateLoops()
			vr.prune(MAX_VINES_IN_RECORD)
		end
	end

	def self.getTodaysVineRecord
		time = Time.new
		year = time.year
		month = time.month
		day = time.day

		ChDir! year
		ChDir! month

		filename = "vineRecord#{day}.json"

		if not File.exists? filename
			#First time today that this function has been called
			VineRecord.create(filename, year, month, day)
		end

		VineRecord.new filename
	end


	#Changes to the subdirectory with the given name,
	#creating it if it doesn't already exist.
	def self.ChDir! dirName
		if not Dir.exists? "#{dirName}"
			Dir.mkdir dirName
		end
		Dir.chdir dirName
	end

end

class VineRecord
	# Creates a new VineRecord (JSON file) in the current directory with the given filename.
	def VineRecord.create(filename, year, month, day)
		fnew = File.new filename
		s = '{'
		s += '"date": "' + month + '/' + day + '/' + year + '",'
		s += '"vines": []'
		s += '}'
		fnew << s
	end

	# Loads an already-created VineRecord (JSON file) into memory
	def initialize filename
		File.open(filename) do |f|
			s = f.gets
			puts "first line of the vineRecord file (should be the entire json string): #{string}"
		end

		@record = JSON.parse(s)
	end

	# Searches the record for the given vine and adds it if it isn't already there.
	def updateVine(vine)
		index = self.getClosestIndex(vine)
		if vines[index].postId != vine.postId # If the given vine is not in the record
			self.insertVine(vine, index)
		end
	end

	# Returns the index of the vine in the record whose postId value
	# is the smallest that is still greater than or equal to
	# the postId of the given vine. If the record does contain
	# the given vine, the returned index is the index of the given vine. If
	# the record does not contain the given vine, the returned index is the
	# index where the given vine should be inserted in order to keep
	# the vines in the record sorted by postId.
	def self.getClosestIndex(vine)
		vines = @record["vines"] # Array of vines in the record, sorted by postId

		vinesWithIndices = [*vines.each_with_index] # An array of [value, index] pairs, one for each element in vines
		closest = vinesWithIndices.bsearch{ |x, _|
			x.postId >= vine.postId # bsearch returns the element at the lowest index where this statement is true
		}
		closestIndex = closest.last # Returns the last element, the index, from the [value, index] pair
	end

	# Inserts the given vine into the record at the 
	# given index.
	# Caution: This record should be kept sorted by postId,
	# so make sure the index you provide is the correct one
	# at which to insert the given vine without corrupting the sort.
	def self.insertVine(vine, index)
		# TODO
	end
end


if __FILE__ == $0
	VineKeeper.updateMostPopular
end