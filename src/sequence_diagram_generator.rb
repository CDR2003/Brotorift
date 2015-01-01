require 'net/http'
require 'uri'
require 'open-uri'


class SequenceDiagramGenerator
	def self.generate runtime
		runtime.sequences.values.each do |sequence|
			generate_sequence sequence
		end
	end

	def self.generate_sequence sequence
		file = "docs/diagrams/#{sequence.name}.png"
		puts 'Generating sequence diagram: ' + file
		text = make_code sequence
		response = Net::HTTP.post_form(URI.parse('http://www.websequencediagrams.com/index.php'), 'style' => 'omegapple', 'message' => text)
		if response.body =~ /img: "(.+)"/
			url = "http://www.websequencediagrams.com/#{ $1 }"
			url.match(/(png)=(.+)$/)
			open url do |content|
				File.open file, 'wb' do |file|
					file.puts content.read
				end
			end
		end
	end

	def self.make_code sequence
		str = "title #{sequence.name} #{sequence.doc}\n"
		sequence.steps.each do |step|
			direction = step.direction
			head = ''
			case direction.direction
			when :left
				head = direction.server.name + ' -> ' + direction.client.name
			when :right
				head = direction.client.name + ' -> ' + direction.server.name
			end
			str += head + ': ' + step.message.name + ' ' + step.doc + "\n"
		end
		str
	end
end