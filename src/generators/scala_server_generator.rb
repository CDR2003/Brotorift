require 'erb'
require_relative '../case_helper'


class BuiltinTypeDef
	def scala
		case @name
		when 'Bool'
			return 'Boolean'
		when 'ByteBuffer'
			return 'ByteString'
		else
			return @name
		end
	end
end


class EnumTypeDef
	def scala
		@name + '.Value'
	end
end


class StructTypeDef
	def scala
		@name
	end
end


class TypeInstanceDef
	def scala
		"#{@type.scala}#{scala_type_param}"
	end

	def scala_type_param
		return '' if @params.empty?
		param_str = @params.map { |p| p.scala } .join ', '
		'[' + param_str + ']'
	end

	def scala_read is_top_scope
		str = ''
		if @type.is_a? StructTypeDef
			str = "packet.readStruct(new #{@type.name})"
		elsif @type.is_a? EnumTypeDef
			str = "#{@type.name}(packet.readInt())"
		else
			str = "packet.read#{scala_type}"
			if @params.empty?
				str += '()'
			else
				param_str = @params.map { |p| p.scala_read false } .join ', '
				str += '(' + param_str + ')'
			end
		end

		unless is_top_scope
			str = '() => ' + str
		end

		str
	end

	def scala_write member_name, is_top_scope
		str = ''
		if @type.is_a? StructTypeDef
			str = "packet.writeStruct(#{member_name})"
		elsif @type.is_a? EnumTypeDef
			str = "packet.writeInt(#{member_name}.id)"
		else
			str = "packet.write#{scala_type}"
			if @params.empty?
				str += "(#{member_name})"
			else
				param_str = @params.map { |p| p.scala_write '_', false } .join ', '
				str += "(#{member_name}, #{param_str})"
			end
		end

		str
	end

	def scala_type
		@type.name + scala_type_param
	end
end


class MemberDef
	def scala_read
		@type.scala_read true
	end

	def scala_write
		@type.scala_write @name, true
	end
end


class MessageDef
	def scala_method
		@name.decapitalize
	end
end


class NodeDirection
	def service_name
		"#{@remote.name}Service"
	end

	def connection_name
		"#{@remote.name}ConnectionBase"
	end
end


class ScalaServerGenerator < Generator
	def initialize
		super 'scala', :server
	end

	def generate node, runtime
		folder = File.expand_path File.dirname __FILE__
		erb_file = folder + '/scala_server_generator.scala.erb'
		template = File.read erb_file
		erb = ERB.new template
		content = erb.result binding
		File.write "#{node.name}.scala", content
	end
end


Generator.add ScalaServerGenerator.new