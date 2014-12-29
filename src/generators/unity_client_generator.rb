require 'erb'
require './case_helper'


class BuiltinTypeDef
	def unity
		case @name
		when 'ByteBuffer'
			return 'byte[]'
		when 'List'
			return 'List'
		when 'Set'
			return 'HashSet'
		when 'Map'
			return 'Dictionary'
		when 'Vector2', 'Vector3'
			return @name
		when 'Matrix4'
			return 'Matrix4x4'
		else
			return @name.decapitalize
		end
	end
end


class EnumTypeDef
	def unity
		@name
	end
end


class StructTypeDef
	def unity
		@name
	end
end


class MemberTypeDef
	def unity
		if @params.empty?
			return @type.unity
		else
			return "#{@type.unity}#{unity_type_param}"
		end
	end

	def unity_read_write
		if @params.empty?
			return @type.name
		else
			return "#{@type.name}#{unity_type_param}"
		end
	end

	def unity_type_param
		return '' if @params.empty?
		param_str = @params.map { |p| p.unity } .join ', '
		'<' + param_str + '>'
	end
end


class MemberDef
	def unity_def
		"public #{unity_param};"
	end

	def unity_param
		"#{@type.unity} #{@name}"
	end

	def unity_read
		"packet.Read#{@type.unity_read_write}();"
	end

	def unity_write
		"packet.Write#{@type.unity_read_write}( #{@name} );"
	end
end


class DirectionDef
	def unity_name
		"#{@client}#{@server}Connector"
	end
end


class MessageDef
	def unity
		param_str = members.map { |m| m.unity_param } .join ', '
		"void #{@name}( #{param_str} )"
	end

	def unity_param
		members.map { |m| m.name } .join ', '
	end
end


class NodeDirection
	def class_name
		"#{@local.name}#{@remote.name}Connector"
	end
end


class UnityClientGenerator < Generator
	def initialize
		super 'unity', :client
	end

	def generate node, runtime
		folder = File.expand_path File.dirname __FILE__
		erb_file = folder + '/unity_client_generator.cs.erb'
		template = File.read erb_file
		erb = ERB.new template
		content = erb.result binding
		File.write "#{node.name}.cs", content
	end
end


Generator.add UnityClientGenerator.new