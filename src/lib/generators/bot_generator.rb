require 'erb'
require_relative '../case_helper'

class EnumTypeDef
    def bot_name
        @name.underscore
    end

    def bot_read_name
        "read_#{self.bot_name}"
    end

    def bot_write_name
        "write_#{self.bot_name}"
    end

    def bot_read
        "#{self.bot_read_name}(data)"
    end

    def bot_write member_name
        "#{self.bot_write_name}(data, #{member_name})"
    end

    def bot_reader
        "#{self.bot_read_name}/1"
    end

    def bot_writer
        "#{self.bot_write_name}/2"
    end

    def bot_type
        @elements.values.map { |e| e.bot_name } .join ' | '
    end
end


class EnumElementDef
    def bot_name
        ':' + @name.underscore
    end
end


class BuiltinTypeDef
    def bot_type
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

    def bot_read
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

    def bot_write member_name
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

    def bot_reader
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

    def bot_writer
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
    def bot_members
        @members.map { |m| ":" + m.bot_name } .join ', '
    end

    def bot_members_with_types node
        @members.map { |m| m.bot_name + ": " + m.type.bot_type(node) } .join ', '
    end

    def bot_members_with_values
        @members.map { |m| m.bot_name + ": " + m.bot_name } .join ', '
    end

    def bot_type node
        "#{node.namespace}.#{@name}.t"
    end

    def bot_read node
        "#{node.namespace}.#{@name}.read(data)"
    end

    def bot_write node, member_name
        "#{node.namespace}.#{@name}.write(data, #{member_name})"
    end

    def bot_reader node
        "&#{node.namespace}.#{@name}.read/1"
    end

    def bot_writer node
        "&#{node.namespace}.#{@name}.write/2"
    end
end


class TypeInstanceDef
    def bot_type node
        return self.bot_list node if @type.name == 'List'
        return self.bot_set node if @type.name == 'Set'
        return self.bot_map node if @type.name == 'Map'
        return @type.bot_type if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.bot_type node if @type.is_a? StructTypeDef
    end

    def bot_read node
        return self.bot_list_read node if @type.name == 'List'
        return self.bot_set_read node if @type.name == 'Set'
        return self.bot_map_read node if @type.name == 'Map'
        return @type.bot_read if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.bot_read node if @type.is_a? StructTypeDef
    end

    def bot_write node, member_name
        return self.bot_list_write node, member_name if @type.name == 'List'
        return self.bot_set_write node, member_name if @type.name == 'Set'
        return self.bot_map_write node, member_name if @type.name == 'Map'
        return @type.bot_write member_name if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.bot_write node, member_name if @type.is_a? StructTypeDef
    end

    def bot_reader node
        return self.bot_list_reader node if @type.name == 'List'
        return self.bot_set_reader node if @type.name == 'Set'
        return self.bot_map_reader node if @type.name == 'Map'
        return @type.bot_reader if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.bot_reader node if @type.is_a? StructTypeDef
    end

    def bot_writer node
        return self.bot_list_writer node if @type.name == 'List'
        return self.bot_set_writer node if @type.name == 'Set'
        return self.bot_map_writer node if @type.name == 'Map'
        return @type.bot_writer if @type.is_a? BuiltinTypeDef or @type.is_a? EnumTypeDef
        return @type.bot_writer node if @type.is_a? StructTypeDef
    end

    def bot_list node
        'list(' + @params[0].bot_type(node)  + ')'
    end

    def bot_list_read node
        'Brotorift.Binary.read_list(data, ' + @params[0].bot_reader(node) + ')'
    end
    
    def bot_list_write node, member_name
        'Brotorift.Binary.write_list(data, ' + member_name + ', ' + @params[0].bot_writer(node) + ')'
    end

    def bot_list_reader node
        '&Brotorift.Binary.read_list(&1, ' + @params[0].bot_reader(node) + ')'
    end

    def bot_list_writer node
        '&Brotorift.Binary.write_list(&1, &2, ' + @params[0].bot_writer(node) + ')'
    end

    def bot_set node
        'MapSet.t(' + @params[0].bot_type(node)  + ')'
    end

    def bot_set_read node
        'Brotorift.Binary.read_set(data, ' + @params[0].bot_reader(node) + ')'
    end
    
    def bot_set_write node, member_name
        'Brotorift.Binary.write_set(data, ' + member_name + ', ' + @params[0].bot_writer(node) + ')'
    end

    def bot_set_reader node
        '&Brotorift.Binary.read_set(&1, ' + @params[0].bot_reader(node) + ')'
    end

    def bot_set_writer node
        '&Brotorift.Binary.write_set(&1, &2, ' + @params[0].bot_writer(node) + ')'
    end

    def bot_map node
        '%{' + @params[0].bot_type(node) + ' => ' + @params[1].bot_type(node) + '}'
    end

    def bot_map_read node
        'Brotorift.Binary.read_map(data, ' + @params[0].bot_reader(node) + ', ' + @params[1].bot_reader(node) + ')'
    end
    
    def bot_map_write node, member_name
        'Brotorift.Binary.write_map(data, ' + member_name + ', ' + @params[0].bot_writer(node) + ', ' + @params[1].bot_writer(node) + ')'
    end

    def bot_map_reader node
        '&Brotorift.Binary.read_map(&1, ' + @params[0].bot_reader(node) + ', ' + @params[1].bot_reader(node) + ')'
    end

    def bot_map_writer node
        '&Brotorift.Binary.write_map(&1, &2, ' + @params[0].bot_writer(node) + ', ' + @params[1].bot_writer(node) + ')'
    end
end


class MemberDef
    def bot_name
        @name.underscore
    end
end


class MessageDef
    def bot_header_name
        "@header_#{self.bot_name}"
    end

    def bot_name
        @name.underscore
    end

    def bot_send_name
        "send_#{self.bot_name}"
    end

    def bot_receive_name
        "receive_#{self.bot_name}"
    end

    def bot_params
        return '' if members.empty?
        params = members.map { |m| m.bot_name } .join ', '
        ', ' + params
    end

    def bot_returns
        return '' if members.empty?
        members.map { |m| m.bot_name } .join ', '
    end

    def bot_params_with_types node
        return '' if members.empty?
        params = members.map { |m| m.bot_name + ' :: ' + m.type.bot_type(node) } .join ', '
        ', ' + params
    end

    def bot_return_types node
        return '' if members.empty?
        members.map { |m| m.type.bot_type(node) }.join ', '
    end
end


class NodeDef
    def bot_name
        @name.underscore
    end

    def bot_client
        @name + 'BotClient'
    end
end


class BotGenerator < Generator
    def initialize
        super 'bot', :client
    end

    def generate node, runtime
        self.generate_file node, runtime, 'bot_types_generator', "#{node.bot_name}_types"
        self.generate_file node, runtime, 'bot_generator', node.bot_name
    end

    def generate_file node, runtime, template_file, generated_file
        folder = File.expand_path File.dirname __FILE__
        erb_file = folder + "/#{template_file}.ex.erb"
        template = File.read erb_file
        erb = ERB.new template
        content = erb.result binding

        output_dir = File.dirname runtime.filename
        output_path = File.join output_dir, "#{generated_file}_bot.ex"
        File.write output_path, content
    end
end


Generator.add BotGenerator.new