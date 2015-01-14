
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
			return "'#{@ast.nickname}' : mickname of nodes should be #{@initial_case} case"
		else
			return "'#{@ast.name}' : mame of #{@type}s should be #{@initial_case} case"
		end
	end
end


class BuiltinNameConflictError < CompilerError
	def initialize ast
		super ast.position
		@name = ast.name
	end

	def info
		"'#{@name}' : type name conflict with built-in type"
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
		"'#{@name}' : #{@type} redefinition\n        #{@old_pos} : see previous #{@type} definition of '#{@name}'"
	end
end


class IncludeFileNotFoundError < CompilerError
	def initialize filename, position
		super position
		@filename = filename
	end

	def info
		"'#{@filename}' : include file not found: "
	end
end


class TypeParamCountMismatchError < CompilerError
	def initialize ast, expected_count
		super ast.position
		@expected_count = expected_count
		@actual_count = ast.params.length
	end

	def info
		"generic parameter count mismatch: expected #{@expected_count}, provided #{@actual_count}"
	end
end


class TypeNotFoundError < CompilerError
	def initialize ast, name
		super ast.position
		@name = name
	end

	def info
		"'#{@name}' : undefined type"
	end
end


class NodeNotFoundError < CompilerError
	def initialize ast, name
		super ast.position
		@name = name
	end

	def info
		"'#{@name}' : undefined node"
	end
end


class CorrespondingNodeNotFoundError < CompilerError
	def initialize member_type_def, node_name
		super member_type_def.ast.position
		@type = member_type_def.type
		@node_name = node_name
	end

	def info
		"'#{@type.name}' : cannot find corresponding node '#{@node_name}'\n        #{@type.ast.position} : see type definition of '#{@type.name}'"
	end
end


class NodeLanguageMismatchError < CompilerError
	def initialize member_type_def, node_def, external_node_def
		super member_type_def.ast.position
		@type = member_type_def.type
		@node_name = node_def.name
		@node_position = node_def.ast.position
		@external_node_position = external_node_def.ast.position
	end

	def info
		"'#{@type.name}' : node language mismatch\n" +
		"        #{@node_position} : see node definition of '#{@node_name}'\n" +
		"        #{@external_node_position} : see external node definition of '#{@node_name}'\n" +
		"        #{@type.ast.position} : see type definition of '#{@type.name}'\n"
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
			"'#{@client.name} -> #{@server.name}' : undefined direction"
		when :right
			"'#{@client.name} <- #{@server.name}' : undefined direction"
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
		"'#{@name}' undefined message in direction '#{@direction.name}'\n        #{@direction.ast.position} : see previous direction definition of '#{@direction.name}'"
	end
end


class ClientServerSameError < CompilerError
	def initialize ast
		super ast.position
	end

	def info
		"client and server of a direction should not be the same"
	end
end


class UnexpectedTokenError < CompilerError
	def initialize token
		super token.position
		@type = token.type
		@value = token.value
	end

	def info
		"unexpected #{@type.to_s.downcase} : '#{@value}'"
	end
end