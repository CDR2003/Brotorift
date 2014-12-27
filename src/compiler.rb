require './parser'


class CompileError < RuntimeError
end


class DuplicateDefError < CompileError
	def initialize type, name, old_def, new_def
		@type = type
		@name = name
		@old_pos = old_def.ast.position
		@new_pos = new_def.ast.position
	end

	def to_s
		"Duplicate #{@type} encountered: '#{@name}' at #{@new_pos}\n    Old #{@type} here: #{@old_pos}"
	end
end


class IncludeFileNotFoundError < CompileError
	def initialize filename, position
		@filename = filename
		@position = position
	end

	def to_s
		"Include file not found: '#{@filename}' at #{@position}"
	end
end


def check_unique type, old_def, new_def
	return if old_def == nil
	raise DuplicateDefError.new type, new_def.name, old_def, new_def
end


class Def
	attr_reader :ast

	def initialize ast
		@ast = ast
	end
end


class EnumElementDef < Def
	attr_reader :name, :value, :doc

	def initialize ast
		super ast
		@name = ast.name
		@value = ast.value
		@doc = ast.doc
	end
end


class EnumDef < Def
	attr_reader :name, :elements, :doc

	def initialize ast
		super ast
		@name = ast.name
		@doc = ast.doc
		@elements = Hash.new
	end

	def get_element name
		@elements[name]
	end

	def add_element element_def
		check_unique 'enum value', self.get_element(element_def.name), element_def
		@elements[element_def.name] = element_def
	end
end


class NodeDef < Def
	attr_reader :name, :language, :nickname, :namespace, :doc

	def initialize ast
		super ast
		@name = ast.name
		@language = ast.language
		@nickname = ast.nickname
		@namespace = ast.namespace
		@doc = ast.doc
	end
end


class Runtime
	attr_reader :nodes
	attr_reader :enums
	attr_reader :structs
	attr_reader :directions
	attr_reader :sequences

	def initialize
		@enums = Hash.new
		@nodes = Hash.new
	end

	def get_enum name
		@enums[name]
	end

	def add_enum enum_def
		check_unique 'enum definition', self.get_enum(enum_def.name), enum_def
		@enums[enum_def.name] = enum_def
	end

	def get_node name_or_nickname
		@nodes[name_or_nickname]
	end

	def add_node node_def
		check_unique 'node definition', self.get_node(node_def.name), node_def
		check_unique 'node definition', self.get_node(node_def.nickname), node_def
		@nodes[node_def.name] = node_def
		@nodes[node_def.nickname] = node_def if node_def.name != node_def.nickname
	end
end


class Compiler
	attr_reader :errors

	def self.compile filename
		compiler = Compiler.new
		runtime = Runtime.new
		compiler.compile_file runtime, filename
		runtime
	end

	def compile_file runtime, filename
		tokens = Lexer::lex_file filename
		Parser::reset
		ast = Parser::parse tokens
		self.compile_ast runtime, ast
	end

	def compile_ast runtime, ast
		ast.each do |decl|
			begin
				case decl
				when IncludeDecl
					compile_include runtime, decl
				when EnumDecl
					compile_enum runtime, decl
				when NodeDecl
					compile_node runtime, decl
				end
			rescue Compiler => e
				@errors.push e
			end
		end
	end

	def compile_include runtime, include_ast
		filename = include_ast.filename + '.b'
		raise IncludeFileNotFoundError.new filename, include_ast.position if not File.exists? filename
		self.compile_file runtime, filename
	end

	def compile_enum runtime, enum_ast
		enum_def = EnumDef.new enum_ast
		enum_ast.elements.each do |element_ast|
			element_def = EnumElementDef.new element_ast
			enum_def.add_element element_def
		end
		runtime.add_enum enum_def
	end

	def compile_node runtime, node_ast
		node_def = NodeDef.new node_ast
		runtime.add_node node_def
	end
end


runtime = Compiler.compile 'test2.b'
puts runtime.nodes.keys