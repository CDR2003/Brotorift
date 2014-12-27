
class CompilerError
	def initialize position
		@position = position
	end

	def to_s
		"#{@position}: #{info}"
	end
end


class InitialCaseError < CompilerError
	def initialize type, initial_case, ast
		super ast.position
		@type = type
		@initial_case = initial_case
		@ast = ast
	end

	def info
		if @type == 'node_nick' then
			return "Nickname of nodes should be #{@initial_case} case: '#{@ast.nickname}'"
		else
			return "Name of #{@type}s should be #{@initial_case} case: '#{@ast.name}'"
		end
	end
end


class BuiltinNameConflictError < CompilerError
	def initialize ast
		super ast.position
		@name = ast.name
	end

	def info
		"Type name conflict with built-in type: #{@name}"
	end
end


class DuplicateDefError < CompilerError
	def initialize type, name, old_ast, new_ast
		super new_ast.position
		@type = type
		@name = name
		@old_pos = old_ast.position
		@new_pos = new_ast.position
	end

	def info
		"Duplicate #{@type} definition encountered: '#{@name}'\n    Previous #{@type} definition here: #{@old_pos}"
	end
end


class IncludeFileNotFoundError < CompilerError
	def initialize filename, position
		super position
		@filename = filename
	end

	def info
		"Include file not found: '#{@filename}'"
	end
end


class TypeParamCountMismatchError < CompilerError
	def initialize ast, expected_count
		super ast.position
		@expected_count = expected_count
		@actual_count = ast.params.length
	end

	def info
		"Generic parameter count mismatch: expected #{@expected_count}, provided #{@actual_count}"
	end
end


class TypeNotFoundError < CompilerError
	def initialize ast, name
		super ast.position
		@name = name
	end

	def info
		"Type not found: '#{@name}'"
	end
end


class NodeNotFoundError < CompilerError
	def initialize ast, name
		super ast.position
		@name = name
	end

	def info
		"Node not found: '#{@name}'"
	end
end


class DirectionNotFoundError < CompilerError
	def initialize ast, client, direction, server
		super ast.position
		@client = client
		@direction = direction
		@server = server
	end

	def info
		case @direction
		when :left
			"Direction not found: #{@client.name} -> #{@server.name}"
		when :right
			"Direction not found: #{@client.name} <- #{@server.name}"
		end
	end
end


class MessageNotFoundError < CompilerError
	def initialize ast, direction
		super ast.position
		@name = ast.message
		@direction = direction
	end

	def info
		"Message not found in direction '#{@direction.name}': '#{@name}'\n    Direction definition here: #{@direction.ast.position}"
	end
end


class ClientServerSameError < CompilerError
	def initialize ast
		super ast.position
	end

	def info
		"Client and server of a direction should not be the same"
	end
end
