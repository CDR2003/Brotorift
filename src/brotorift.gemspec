Gem::Specification.new do |s|
    s.name = 'brotorift'
    s.version = '0.8.0'
    s.date = '2018-05-23'
    s.summary = 'Brotorift'
    s.description = 'Brotorift generator'
    s.author = 'Peter Ren'
    s.email = 'lcdcdr2004@gmail.com'
    s.homepage = 'http://rubygems.org/gems/brotorift'
    s.license = 'MIT'

    s.executables << 'brotorift'

    s.add_runtime_dependency 'colorize', '~> 0.7'
    s.add_runtime_dependency 'rltk', '~> 3.0'
    s.add_runtime_dependency 'filigree', '= 0.2.0'

    s.files = [
        'lib/ast.rb',
        'lib/brotorift.rb',
        'lib/case_helper.rb',
        'lib/compiler.rb',
        'lib/compiler_error.rb',
        'lib/lexer.rb',
        'lib/parser.rb',
        'lib/runtime.rb',
        'lib/sequence_diagram_generator.rb',
        'lib/generators/elixir_server_generator.ex.erb',
        'lib/generators/elixir_server_types_generator.ex.erb',
        'lib/generators/elixir_server_generator.rb',
        'lib/generators/scala_server_generator.scala.erb',
        'lib/generators/scala_server_generator.rb',
        'lib/generators/unity_client_generator.cs.erb',
        'lib/generators/unity_client_generator.rb',
    ]
end