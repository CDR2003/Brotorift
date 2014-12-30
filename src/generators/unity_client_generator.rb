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


class TypeInstanceDef
	@@lambda_index = 0

	def unity
		if @params.empty?
			return @type.unity
		else
			return "#{@type.unity}#{unity_type_param}"
		end
	end

	def unity_read is_top_scope
		str = "packet.Read#{unity_read_write}"
		if @params.empty?
			str += '()'
		else
			param_str = @params.map { |p| p.unity_read false } .join ', '
			str += '( ' + param_str + ' )'
		end

		if is_top_scope == false
			str = '() => ' + str
		end

		str
	end

	def unity_write member_name, is_top_scope
		str = "packet.Write#{unity_read_write}"
		if @params.empty?
			str += "( #{member_name} )"
		else
			params_str = @params.map do |p|
				@@lambda_index += 1
				arg_name = '_' + @@lambda_index.to_s
				p.unity_write arg_name, false
			end
			param_str = params_str.join ', '
			str += '( ' + param_str + ' )'
		end

		if is_top_scope == false
			str = "( #{member_name} ) => " + str
		end

		str
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
		"var #{@name} = #{@type.unity_read true};"
	end

	def unity_write
		"#{@type.unity_write @name, true};"
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