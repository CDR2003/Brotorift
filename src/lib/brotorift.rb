require 'colorize'
require_relative 'compiler'
require_relative 'sequence_diagram_generator'


class Generator
	attr_reader :language, :side

	@@generators = []

	def initialize language, side
		@language = language
		@side = side
	end

	def self.add generator
		@@generators.push generator
	end

	def self.generators
		@@generators
	end
end


class Brotorift
	def initialize
		@generated_nodes = {}
	end

	def load_generators
		root_folder = File.expand_path File.dirname __FILE__
		generators_pattern = root_folder + '/generators/*.rb'
		Dir.glob generators_pattern do |generator_file|
			require generator_file
		end
	end
	
	
	def print_compile_errors errors
		errors.each do |e|
			puts e
		end
		puts 'Your brotorift files contain errors. Please fix them before go on.'.red
	end
	
	
	def generate_all_code runtime, generate_diagram
		runtime.directions.each do |direction|
			generate_code runtime, direction.client, :client
			generate_code runtime, direction.server, :server
			generate_bot_code runtime, direction.client
		end
	
		generate_sequence_diagrams runtime if generate_diagram
	end
	
	
	def generate_sequence_diagrams runtime
		begin
			Dir.mkdir 'docs'
			Dir.mkdir 'docs/diagrams'
		rescue
		end
		SequenceDiagramGenerator.generate runtime
	end
	
	
	def generate_code runtime, node, side
		old_sides = @generated_nodes[node.name]
		return if old_sides != nil and old_sides.include? side
	
		generator = find_generator node.language, side
		if generator == nil
			puts "Generator for language '#{node.language}' and side #{side} is not found.".red
			return
		end
	
		puts "Generating #{node.language} #{side} code for node '#{node.name}'..."
		generator.generate node, runtime
		if old_sides != nil
			old_sides.push side
		else
			@generated_nodes[node.name] = [side]
		end
	end

	def generate_bot_code runtime, node
		generator = find_generator 'bot', :client
		if generator == nil
			puts "Generator for bot is not found.".red
			return
		end
	
		puts "Generating bot code for node '#{node.name}'..."
		generator.generate node, runtime
	end
	
	def find_generator language, side
		Generator.generators.find { |g| g.language == language and g.side == side }
	end
	
	def run file_name, generate_diagram
		load_generators
		compiler = Compiler.new
		compiler.compile file_name, true
		if compiler.errors.length > 0
			print_compile_errors compiler.errors
			exit 1
		else
			generate_all_code compiler.runtime, generate_diagram
		end
	end
end