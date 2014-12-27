require 'rltk/ast'
require './lexer'


class ASTNode < RLTK::ASTNode
	def doc_str
		if doc == ''
			return ''
		else
			return " # #{doc}"
		end
	end
end

class Decl < ASTNode
end

class IncludeDecl < Decl
	value :filename, String

	def to_s
		"include '#{filename}'"
	end
end

class NodeDecl < Decl
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

class TypeDef < ASTNode
	value :name, String
	value :params, [String]

	def to_s
		params_str = ''
		params_str = '<' + params.join(', ') + '>' if params.length > 0
		"#{name}#{params_str}"
	end
end

class MemberDef < ASTNode
	value :type, TypeDef
	value :name, String
	value :doc, String

	def to_s
		"#{type} #{name}#{doc_str}\n"
	end
end

class StructDecl < Decl
	value :name, String
	value :doc, String
	child :members, [MemberDef]

	def to_s
		members_str = members.join ''
		"struct #{name}#{doc_str}\n#{members_str}end"
	end
end

class EnumElementDef < ASTNode
	value :name, String
	value :value, Fixnum
	value :doc, String

	def to_s
		"#{name} = #{value}#{doc_str}\n"
	end
end

class EnumDecl < Decl
	value :name, String
	value :doc, String
	child :elements, [EnumElementDef]

	def to_s
		elements_str = elements.join ''
		"enum #{name}#{doc_str}\n#{elements_str}end"
	end
end

class MessageDef < ASTNode
	value :name, String
	value :doc, String
	child :members, [MemberDef]

	def to_s
		members_str = members.join ''
		"message #{name}#{doc_str}\n#{members_str}end\n"
	end
end

class DirectionDecl < Decl
	value :client, String
	value :direction, String
	value :server, String
	value :doc, String
	child :messages, [MessageDef]

	def to_s
		messages_str = messages.join ''
		"direction #{client} #{direction} #{server}#{doc_str}\n#{messages_str}end"
	end
end

class StepDef < ASTNode
	value :from, String
	value :to, String
	value :message, String
	value :doc, String

	def to_s
		"#{from} -> #{to}: #{message}#{doc_str}\n"
	end
end

class SequenceDecl < Decl
	value :name, String
	value :doc, String
	child :steps, [StepDef]

	def to_s
		steps_str = steps.join ''
		"sequence #{name}#{doc_str}\n#{steps_str}end"
	end
end

class Program < ASTNode
	child :decls, [Decl]
end