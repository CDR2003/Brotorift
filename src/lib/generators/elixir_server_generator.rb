require 'erb'
require_relative '../case_helper'

class EnumTypeDef
    def elixir_name
        @name.underscore
    end

    def elixir_read_name
        "read_#{self.elixir_name}"
    end

    def elixir_write_name
        "write_#{self.elixir_name}"
    end

    def elixir_read
        "#{self.elixir_read_name}(data)"
    end

    def elixir_write member_name
        "#{self.elixir_write_name}(data, #{member_name})"
    end

    def elixir_reader
        "#{self.elixir_read_name}/1"
    end

    def elixir_writer
        "#{self.elixir_write_name}/2"
    end

    def elixir_type
        @elements.values.map { |e| e.elixir_name } .join ' | '
    end
end


class EnumElementDef
    def elixir_name
        ':' + @name.underscore
    end
end


class BuiltinTypeDef
    def elixir_type
        case @name
        when 'Bool'
            return 'boolean()'
        when 'Byte'
            return 'byte()'
        when 'Short'
            return 'integer()'
        when 'Int'
            return 'integer()'
        when 'Long'
            return 'integer()'
        when 'UShort'
            return 'non_neg_integer()'
        when 'UInt'
            return 'non_neg_integer()'
        when 'ULong'
            return 'non_neg_integer()'
        when 'Float'
            return 'float()'
        when 'Double'
            return 'float()'
        when 'String'
            return 'String.t()'
        when 'DateTime'
            return 'DateTime.t()'
        when 'ByteBuffer'
            return 'binary()'
        when 'Vector2'
            return '{float(), float()}'
        when 'Vector3'
            return '{float(), float(), float()}'
        when 'Color'
            return '{float(), float(), float(), float()}'
        else
            return @name
        end
    end

    def elixir_read
        case @name
        when 'Bool'
            return "Brotorift.Binary.read_bool(data)"
        when 'Byte'
            return "Brotorift.Binary.read_byte(data)"
        when 'Short'
            return "Brotorift.Binary.read_short(data)"
        when 'Int'
            return "Brotorift.Binary.read_int(data)"
        when 'Long'
            return "Brotorift.Binary.read_long(data)"
        when 'UShort'
            return "Brotorift.Binary.read_ushort(data)"
        when 'UInt'
            return "Brotorift.Binary.read_uint(data)"
        when 'ULong'
            return "Brotorift.Binary.read_ulong(data)"
        when 'Float'
            return "Brotorift.Binary.read_float(data)"
        when 'Double'
            return "Brotorift.Binary.read_double(data)"
        when 'String'
            return "Brotorift.Binary.read_string(data)"
        when 'ByteBuffer'
            return "Brotorift.Binary.read_byte_buffer(data)"
        when 'Vector2'
            return "Brotorift.Binary.read_vector2(data)"
        when 'Vector3'
            return "Brotorift.Binary.read_vector3(data)"
        when 'Color'
            return "Brotorift.Binary.read_color(data)"
        else
            throw 'Invalid operation'
        end
    end

    def elixir_write member_name
        case @name
        when 'Bool'
            return "Brotorift.Binary.write_bool(data, #{member_name})"
        when 'Byte'
            return "Brotorift.Binary.write_byte(data, #{member_name})"
        when 'Short'
            return "Brotorift.Binary.write_short(data, #{member_name})"
        when 'Int'
            return "Brotorift.Binary.write_int(data, #{member_name})"
        when 'Long'
            return "Brotorift.Binary.write_long(data, #{member_name})"
        when 'UShort'
            return "Brotorift.Binary.write_ushort(data, #{member_name})"
        when 'UInt'
            return "Brotorift.Binary.write_uint(data, #{member_name})"
        when 'ULong'
            return "Brotorift.Binary.write_ulong(data, #{member_name})"
        when 'Float'
            return "Brotorift.Binary.write_float(data, #{member_name})"
        when 'Double'
            return "Brotorift.Binary.write_double(data, #{member_name})"
        when 'String'
            return "Brotorift.Binary.write_string(data, #{member_name})"
        when 'ByteBuffer'
            return "Brotorift.Binary.write_byte_buffer(data, #{member_name})"
        when 'Vector2'
            return "Brotorift.Binary.write_vector2(data, #{member_name})"
        when 'Vector3'
            return "Brotorift.Binary.write_vector3(data, #{member_name})"
        when 'Color'
            return "Brotorift.Binary.write_color(data, #{member_name})"
        else
            throw 'Invalid operation'
        end
    end

    def elixir_reader
        case @name
        when 'Bool'
            return "&Brotorift.Binary.read_bool/1"
        when 'Byte'
            return "&Brotorift.Binary.read_byte/1"
        when 'Short'
            return "&Brotorift.Binary.read_short/1"
        when 'Int'
            return "&Brotorift.Binary.read_int/1"
        when 'Long'
            return "&Brotorift.Binary.read_long/1"
        when 'UShort'
            return "&Brotorift.Binary.read_ushort/1"
        when 'UInt'
            return "&Brotorift.Binary.read_uint/1"
        when 'ULong'
            return "&Brotorift.Binary.read_ulong/1"
        when 'Float'
            return "&Brotorift.Binary.read_float/1"
        when 'Double'
            return "&Brotorift.Binary.read_double/1"
        when 'String'
            return "&Brotorift.Binary.read_string/1"
        when 'ByteBuffer'
            return "&Brotorift.Binary.read_byte_buffer/1"
        when 'Vector2'
            return "&Brotorift.Binary.read_vector2/1"
        when 'Vector3'
            return "&Brotorift.Binary.read_vector3/1"
        when 'Color'
            return "&Brotorift.Binary.read_color/1"
        else
            throw 'Invalid operation'
        end
    end

    def elixir_writer
        case @name
        when 'Bool'
            return "&Brotorift.Binary.write_bool/2"
        when 'Byte'
            return "&Brotorift.Binary.write_byte/2"
        when 'Short'
            return "&Brotorift.Binary.write_short/2"
        when 'Int'
            return "&Brotorift.Binary.write_int/2"
        when 'Long'
            return "&Brotorift.Binary.write_long/2"
        when 'UShort'
            return "&Brotorift.Binary.write_ushort/2"
        when 'UInt'
            return "&Brotorift.Binary.write_uint/2"
        when 'ULong'
            return "&Brotorift.Binary.write_ulong/2"
        when 'Float'
            return "&Brotorift.Binary.write_float/2"
        when 'Double'
            return "&Brotorift.Binary.write_double/2"
        when 'String'
            return "&Brotorift.Binary.write_string/2"
        when 'ByteBuffer'
            return "&Brotorift.Binary.write_byte_buffer/2"
        when 'Vector2'
            return "&Brotorift.Binary.write_vector2/2"
        when 'Vector3'
            return "&Brotorift.Binary.write_vector3/2"
        when 'Color'
            return "&Brotorift.Binary.write_color/2"
        else
            throw 'Invalid operation'
        end
    end
end


class StructTypeDef
    def elixir_members
        @members.map { |m| ":" + m.elixir_name } .join ', '
    end

    def elixir_members_with_types node
        @members.map { |m| m.elixir_name + ": " + m.type.elixir_type(node) } .join ', '
    end

    def elixir_members_with_values
        @members.map { |m| m.elixir_name + ": " + m.elixir_name } .join ', '
    end

    def elixir_type node
        "#{node.namespace}.#{@name}.t"
    end

    def elixir_read node
        "#{node.namespace}.#{@name}.read(data)"
    end

    def elixir_write node, member_name
        "#{node.namespace}.#{@name}.write(data, #{member_name})"
    end

    def elixir_reader node
        "&#{node.namespace}.#{@name}.read/1"
    end

    def elixir_writer node
        "&#{node.namespace}.#{@name}.write/2"
    end
end


class TypeInstanceDef
    def elixir_type node
        return self.elixir_list node if @type.name == 'List'
        return self.elixir_set node if @type.name == 'Set'
        return self.elixir_map node if @type.name == 'Map'
        return @type.elixir_type if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.elixir_type node if @type.is_a? StructTypeDef
    end

    def elixir_read node
        return self.elixir_list_read node if @type.name == 'List'
        return self.elixir_set_read node if @type.name == 'Set'
        return self.elixir_map_read node if @type.name == 'Map'
        return @type.elixir_read if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.elixir_read node if @type.is_a? StructTypeDef
    end

    def elixir_write node, member_name
        return self.elixir_list_write node, member_name if @type.name == 'List'
        return self.elixir_set_write node, member_name if @type.name == 'Set'
        return self.elixir_map_write node, member_name if @type.name == 'Map'
        return @type.elixir_write member_name if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.elixir_write node, member_name if @type.is_a? StructTypeDef
    end

    def elixir_reader node
        return self.elixir_list_reader node if @type.name == 'List'
        return self.elixir_set_reader node if @type.name == 'Set'
        return self.elixir_map_reader node if @type.name == 'Map'
        return @type.elixir_reader if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.elixir_reader node if @type.is_a? StructTypeDef
    end

    def elixir_writer node
        return self.elixir_list_writer node if @type.name == 'List'
        return self.elixir_set_writer node if @type.name == 'Set'
        return self.elixir_map_writer node if @type.name == 'Map'
        return @type.elixir_writer if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.elixir_writer node if @type.is_a? StructTypeDef
    end

    def elixir_list node
        'list(' + @params[0].elixir_type(node)  + ')'
    end

    def elixir_list_read node
        'Brotorift.Binary.read_list(data, ' + @params[0].elixir_reader(node) + ')'
    end
    
    def elixir_list_write node, member_name
        'Brotorift.Binary.write_list(data, ' + member_name + ', ' + @params[0].elixir_writer(node) + ')'
    end

    def elixir_list_reader node
        '&Brotorift.Binary.read_list(&1, ' + @params[0].elixir_reader(node) + ')'
    end

    def elixir_list_writer node
        '&Brotorift.Binary.write_list(&1, &2, ' + @params[0].elixir_writer(node) + ')'
    end

    def elixir_set node
        'MapSet.t(' + @params[0].elixir_type(node)  + ')'
    end

    def elixir_set_read node
        'Brotorift.Binary.read_set(data, ' + @params[0].elixir_reader(node) + ')'
    end
    
    def elixir_set_write node, member_name
        'Brotorift.Binary.write_set(data, ' + member_name + ', ' + @params[0].elixir_writer(node) + ')'
    end

    def elixir_set_reader node
        '&Brotorift.Binary.read_set(&1, ' + @params[0].elixir_reader(node) + ')'
    end

    def elixir_set_writer node
        '&Brotorift.Binary.write_set(&1, &2, ' + @params[0].elixir_writer(node) + ')'
    end

    def elixir_map node
        '%{' + @params[0].elixir_type(node) + ' => ' + @params[1].elixir_type(node) + '}'
    end

    def elixir_map_read node
        'Brotorift.Binary.read_map(data, ' + @params[0].elixir_reader(node) + ', ' + @params[1].elixir_reader(node) + ')'
    end
    
    def elixir_map_write node, member_name
        'Brotorift.Binary.write_map(data, ' + member_name + ', ' + @params[0].elixir_writer(node) + ', ' + @params[1].elixir_writer(node) + ')'
    end

    def elixir_map_reader node
        '&Brotorift.Binary.read_map(&1, ' + @params[0].elixir_reader(node) + ', ' + @params[1].elixir_reader(node) + ')'
    end

    def elixir_map_writer node
        '&Brotorift.Binary.write_map(&1, &2, ' + @params[0].elixir_writer(node) + ', ' + @params[1].elixir_writer(node) + ')'
    end
end


class MemberDef
    def elixir_name
        @name.underscore
    end
end


class MessageDef
    def elixir_header_name
        "@header_#{self.elixir_name}"
    end

    def elixir_name
        @name.underscore
    end

    def elixir_params
        return '' if members.empty?
        params = members.map { |m| m.elixir_name } .join ', '
        ', ' + params
    end

    def elixir_params_with_types node
        return '' if members.empty?
        params = members.map { |m| m.elixir_name + ' :: ' + m.type.elixir_type(node) } .join ', '
        ', ' + params
    end
end


class NodeDef
    def elixir_name
        @name.underscore
    end

    def elixir_connection
        @name + 'Connection'
    end

    def elixir_behaviour
        @name + 'Behaviour'
    end
end


class ElixirServerGenerator < Generator
    def initialize
        super 'elixir', :server
    end

    def generate node, runtime
        self.generate_file node, runtime, 'elixir_server_types_generator', "#{node.elixir_name}_types"
        self.generate_file node, runtime, 'elixir_server_generator', node.elixir_name
    end

    def generate_file node, runtime, template_file, generated_file
        folder = File.expand_path File.dirname __FILE__
        erb_file = folder + "/#{template_file}.ex.erb"
        template = File.read erb_file
        erb = ERB.new template
        content = erb.result binding

        output_dir = File.dirname runtime.filename
        output_path = File.join output_dir, "#{generated_file}.ex"
        File.write output_path, content
    end
end


Generator.add ElixirServerGenerator.new