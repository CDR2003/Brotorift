class UnityClientGenerator < Generator
	def initialize
		super 'unity', :client
	end

	def generate node, runtime
		
	end
end


Generator.add UnityClientGenerator.new