require 'rltk'
require './ast'


module RLTK
	class Parser
		class Environment
			def position
				Position.new @positions.first, @positions.last
			end
		end
	end
end


class Parser < RLTK::Parser
	def self.reset
		@@enum_value = 0
	end

	@@enum_value = 0

	list(:decl_list, :decl)

	production(:decl) do
		clause('include_decl')										{ |d| d }
		clause('node_decl')											{ |d| d }
		clause('struct_decl')										{ |d| d }
		clause('enum_decl')											{ |d| d }
		clause('direction_decl')									{ |d| d }
		clause('sequence_decl')										{ |d| d }
	end

	production(:include_decl) do
		clause('INCLUDE STRING')									{ |_, filename| IncludeDecl.new self.position, filename }
	end

	production(:node_decl) do
		clause('NODE IDENT IDENT doc')								{ |_, language, name, doc| NodeDecl.new self.position, name, language, name, '', doc }
		clause('NODE IDENT IDENT AS IDENT doc')						{ |_, language, name, _, nickname, doc| NodeDecl.new self.position, name, language, nickname, '', doc }
		clause('NODE IDENT IDENT NAMESPACE namespace doc')			{ |_, language, name, _, namespace, doc| NodeDecl.new self.position, name, language, name, namespace, doc }
		clause('NODE IDENT IDENT AS IDENT NAMESPACE namespace doc')	{ |_, language, name, _, nickname, _, namespace, doc| NodeDecl.new self.position, name, language, nickname, namespace, doc }
	end

	production(:namespace) do
		clause('IDENT')												{ |name| name }
		clause('IDENT DOT namespace')								{ |name, _, rest| name + '.' + rest }
	end

	production(:doc) do
		clause('')													{ || '' }
		clause('DOCUMENT')											{ |doc| doc }
	end

	production(:struct_decl) do
		clause('STRUCT IDENT doc member_list END')					{ |_, name, doc, members, _| StructDecl.new self.position, name, doc, members }
	end

	list(:member_list, :member)

	production(:member) do
		clause('type IDENT doc')									{ |type, name, doc| MemberDecl.new self.position, type, name, doc }
	end

	production(:type) do
		clause('IDENT')												{ |name| TypeDecl.new self.position, name, [] }
		clause('IDENT LANGLE type_param_list RANGLE')				{ |name, _, params, _| TypeDecl.new self.position, name, params }
	end

	nonempty_list(:type_param_list, :IDENT, :COMMA)

	production(:enum_decl) do
		clause('ENUM IDENT doc element_list END')					{ |_, name, doc, elements, _| @@enum_value = 0; EnumDecl.new self.position, name, doc, elements }
	end

	list(:element_list, :element)

	production(:element) do
		clause('IDENT doc')											{ |name, doc| @@enum_value += 1; EnumElementDecl.new self.position, name, @@enum_value - 1, doc }
		clause('IDENT ASSIGN NUMBER doc')							{ |name, _, value, doc| @@enum_value = value + 1; EnumElementDecl.new self.position, name, @@enum_value - 1, doc }
	end

	production(:direction_decl) do
		clause('DIRECTION IDENT arrow IDENT doc message_list END')	{ |_, client, direction, server, doc, messages, _| DirectionDecl.new self.position, client, direction, server, doc, messages }
	end

	production(:arrow) do
		clause('LARROW')											{ |_| '<-' }
		clause('RARROW')											{ |_| '->' }
	end

	list(:message_list, :message)

	production(:message) do
		clause('MESSAGE IDENT doc member_list END')					{ |_, name, doc, members, _| MessageDecl.new self.position, name, doc, members }
	end

	production(:sequence_decl) do
		clause('SEQUENCE IDENT doc step_list END')					{ |_, name, doc, steps, _| SequenceDecl.new self.position, name, doc, steps }
	end

	list(:step_list, :step)

	production(:step) do
		clause('IDENT RARROW IDENT COLON IDENT doc')				{ |from, _, to, _, message, doc| StepDecl.new self.position, from, to, message, doc }
	end

	finalize
end
