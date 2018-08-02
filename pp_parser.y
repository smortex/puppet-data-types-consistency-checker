class PpParser
rule
  target: class_definition
        | type_definition

  class_definition: CLASS IDENTIFIER '(' parameters ')' inherits BLOCK
                  | CLASS IDENTIFIER inherits BLOCK

  inherits: INHERITS IDENTIFIER
          |

  type_definition: DEFINE IDENTIFIER '(' parameters ')' BLOCK
                 | DEFINE IDENTIFIER BLOCK

  parameters: parameters parameter
            | parameter
  
  parameter: type VARIABLE '=' value ',' { @variables[val[1]] = val[0] }
           | type VARIABLE ','           { @variables[val[1]] = val[0] }

  type: TYPE '[' type_list ']'   { result = val.join }
      | TYPE '[' string_list ']' { result = val.join }
      | TYPE                     { result = val[0] }

  type_list: type_list ',' type { result = val.join }
           | type { result = val.join }

  string_list: string_list ',' STRING { result = val.join }
             | STRING { result = val.join }

  value: UNDEF
       | STRING
       | TRUE
       | FALSE
       | NUMBER
       | VARIABLE dereferences
       | VARIABLE
       | '[' ']'
       | '[' string_list ']'
       | '[' string_list ',' ']' # FIXME
       | BLOCK
       | resource_reference
       | function_call

  dereferences: dereferences dereference
              | dereference

  dereference: '[' STRING ']'
             | '[' VARIABLE ']'

  resource_reference: TYPE '[' STRING ']'
                    | TYPE '[' VARIABLE ']'

  function_call: IDENTIFIER '(' value_list ')'

  value_list: value_list ',' value
            | value
end

---- header

require 'strscan'

---- inner

  attr_accessor :yydebug
  attr_reader :variables

  def parse(text)
    s = StringScanner.new text

    tokens = []
    case
    when s.scan(/#.*/);           # Ignore comments
    when s.scan(/\s+/);           # Ignore spaces
    when s.scan(/class/);      tokens << [:CLASS, s.matched]
    when s.scan(/define/);     tokens << [:DEFINE, s.matched]
    when s.scan(/inherits/);   tokens << [:INHERITS, s.matched]
    when s.scan(/[A-Z][a-zA-Z_]*(::[A-Z][a-zA-Z_]*)*/);tokens << [:TYPE, s.matched]
    when s.scan(/\$[a-z:_]+/);
      name = s.matched
      if name.end_with?(':')
        name.chomp!(':')
	s.pos -= 1
      end
      tokens << [:VARIABLE, name]
    when s.scan(/'[^']*'/);       tokens << [:STRING, s.matched]
    when s.scan(/"[^"]*"/);       tokens << [:STRING, s.matched]
    when s.scan(/[[:digit:]]+/);  tokens << [:NUMBER, s.matched]
    when s.scan(/\(/);            tokens << ['(', s.matched]
    when s.scan(/\)/);            tokens << [')', s.matched]
    when s.scan(/\[/);            tokens << ['[', s.matched]
    when s.scan(/\]/);            tokens << [']', s.matched]
    when s.scan(/{/);
      start = s.pos - 1
      pos = s.pos
      level = 1
      while level > 0 do
        pos += 1
        level -= 1 if text[pos] == '}'
        level += 1 if text[pos] == '{'
      end
      s.pos = pos + 1
      tokens << [:BLOCK, text[start..pos]]
    when s.scan(/=>/);            tokens << [:SPACESHIP, s.matched]
    when s.scan(/=/);             tokens << ['=', s.matched]
    when s.scan(/:/);             tokens << [':', s.matched]
    when s.scan(/,/);             tokens << [',', s.matched]
    when s.scan(/true/);          tokens << [:TRUE, s.matched]
    when s.scan(/false/);         tokens << [:FALSE, s.matched]
    when s.scan(/undef/);         tokens << [:UNDEF, s.matched]
    when s.scan(/include|require/);       tokens << [:INCLUDE, s.matched]
    when s.scan(/if/);            tokens << [:IF, s.matched]
    when s.scan(/(@@)?[a-z:_]+/);      tokens << [:IDENTIFIER, s.matched]
    else
      puts "No match: #{s.rest}"
      exit 1
    end until s.eos?

    define_singleton_method(:next_token) { tokens.shift }

    tokens << [false, false]

    # tokens.each do |t|
    #   puts t.inspect
    # end

    do_parse
  end

  def initialize
    super
    @variables = {}
  end
