require 'rltk/ast'
require './lexer'


class Position
	attr_reader :start, :stop

	def initialize start, stop
		raise "Filename should be the same." if start.file_name != stop.file_name
		@start = start
		@stop = stop
	end

	def to_s
		"#{@start.file_name}:#{@start.line_number}:#{@start.line_offset} - #{@stop.line_number}:#{@stop.line_offset}"
	end
end


class ASTNode < RLTK::ASTNode
	value :position, Position

	def doc_str
		if doc == ''
			return ''
		else
			return " # #{doc}"
		end
	end
end

class TopDecl < ASTNode
end

class IncludeDecl < TopDecl
	value :filename, String

	def to_s
		"include '#{filename}'"
	end
end

class NodeDecl < TopDecl
	value :name, String
	value :language, String
	value :nickname, String
	value :namespace, String
	value :doc, String

	def to_s
		nickname_str = ''
		nickname_str = " as #{nickname}" if nickname != name
		namespace_str = ''
		namespace_str = " namespace #{namespace}" if namespace != ''
		"node #{language} #{name}#{nickname_str}#{namespace_str}#{doc_str}"
	end
end

class TypeDecl < ASTNode
	value :name, String
	value :params, [String]

	def to_s
		params_str = ''
		params_str = '<' + params.join(', ') + '>' if params.length > 0
		"#{name}#{params_str}"
	end
end

class MemberDecl < ASTNode
	value :type, TypeDecl
	value :name, String
	value :doc, String

	def to_s
		"#{type} #{name}#{doc_str}\n"
	end
end

class StructDecl < TopDecl
	value :name, String
	value :doc, String
	child :members, [MemberDecl]

	def to_s
		members_str = members.join ''
		"struct #{name}#{doc_str}\n#{members_str}end"
	end
end

class EnumElementDecl < ASTNode
	value :name, String
	value :value, Fixnum
	value :doc, String

	def to_s
		"#{name} = #{value}#{doc_str}\n"
	end
end

class EnumDecl < TopDecl
	value :name, String
	value :doc, String
	child :elements, [EnumElementDecl]

	def to_s
		elements_str = elements.join ''
		"enum #{name}#{doc_str}\n#{elements_str}end"
	end
end

class MessageDecl < ASTNode
	value :name, String
	value :doc, String
	child :members, [MemberDecl]

	def to_s
		members_str = members.join ''
		"message #{name}#{doc_str}\n#{members_str}end\n"
	end
end

class DirectionDecl < TopDecl
	value :client, String
	value :direction, String
	value :server, String
	value :doc, String
	child :messages, [MessageDecl]

	def to_s
		messages_str = messages.join ''
		"direction #{client} #{direction} #{server}#{doc_str}\n#{messages_str}end"
	end
end

class StepDecl < ASTNode
	value :from, String
	value :to, String
	value :message, String
	value :doc, String

	def to_s
		"#{from} -> #{to}: #{message}#{doc_str}\n"
	end
end

class SequenceDecl < TopDecl
	value :name, String
	value :doc, String
	child :steps, [StepDecl]

	def to_s
		steps_str = steps.join ''
		"sequence #{name}#{doc_str}\n#{steps_str}end"
	end
end
