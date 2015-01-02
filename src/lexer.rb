require 'rltk'


class Lexer < RLTK::Lexer
	# Whitespace
	rule(/\s/)

	# Keyword
	rule(/namespace/)				{ :NAMESPACE }
	rule(/include/)					{ :INCLUDE }
	rule(/node/)					{ :NODE }
	rule(/as/)						{ :AS }
	rule(/struct/)					{ :STRUCT }
	rule(/enum/)					{ :ENUM }
	rule(/direction/)				{ :DIRECTION }
	rule(/message/)					{ :MESSAGE }
	rule(/sequence/)				{ :SEQUENCE }
	rule(/end/)						{ :END }

	# Operator
	rule(/\./)						{ :DOT }
	rule(/\=/)						{ :ASSIGN }
	rule(/<-/)						{ :LARROW }
	rule(/->/)						{ :RARROW }
	rule(/:/)						{ :COLON }
	rule(/</)						{ :LANGLE }
	rule(/>/)						{ :RANGLE }
	rule(/,/)						{ :COMMA }

	# Number
	rule(/(\+|-)?\d+/)				{ |t| [:NUMBER, t.to_i] }
	rule(/0[xX][0-9a-fA-F]+/)		{ |t| [:NUMBER, t.hex] }

	# String
	rule(/'.+'/)					{ |t| [:STRING, t[1..-2]] }

	# Identifier
	rule(/[A-Za-z_][A-Za-z0-9_]*/)	{ |t| [:IDENT, t] }

	# Document
	rule(/#.*/)						{ |t| [:DOCUMENT, t[1..-1].strip] }
end
