class VineCompiler

	def self.readCategories
		categoryListFileName = 'CategoryList.txt'
		
		if not File.exists? categoryListFileName
			#TODO: logError '#{categoryListFileName} is not present.'
			puts "#{categoryListFileName} is not present."
			return
		end

		categories = []
		File.open(categoryListFileName) do |f|
			while line = f.gets do
				categories.push(line)
			end
		end

		return categories
	end
end