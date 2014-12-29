class String
	def decapitalize
		self[0].downcase + self[1..-1]
	end
end