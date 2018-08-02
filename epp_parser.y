class EppParser
rule
  target: expression_tag
        | expression_printing_tag
	| parameter_tag
	| comment_tag

  expression_tag: OPEN_TAG expressions CLOSE_TAG
  
  expression_printing_tag: OPEN_TAG_P expressions CLOSE_TAG

  parameter_tag: OPEN_TAG PIPE variable_definitions PIPE CLOSE_TAG

  comment_tag: COMMENT

  expressions: expressions expression
             | expression

  expression: VARIABLE
            | THING
	    | PIPE
	    | COMA

  variable_definitions: variable_definitions variable_definition
                      | variable_definition

  variable_definition: THING VARIABLE COMA { @variables[val[1]] = val[0] }
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
    when s.scan(/\s+/);            # Ignore white space
    when s.scan(/#.*/);            # Ignore comments to end of line
    when s.scan(/<%#.*%>/);        tokens << [:COMMENT, s.matched]
    when s.scan(/<%=/);            tokens << [:OPEN_TAG_P, s.matched]
    when s.scan(/<%-?/);           tokens << [:OPEN_TAG, s.matched]
    when s.scan(/-?%>/);           tokens << [:CLOSE_TAG, s.matched]
    when s.scan(/\|/);             tokens << [:PIPE, s.matched]
    when s.scan(/,/);              tokens << [:COMA, s.matched]
    when s.scan(/\$[a-z_:]+(\[['"][a-z_]+['"]\])*/);     tokens << [:VARIABLE, s.matched]
    when s.scan(/[^[:space:]<]+/); tokens << [:THING, s.matched]
    end until s.eos?

    define_singleton_method(:next_token) { tokens.shift }

    tokens << [false, false]

    # puts "==> #{text}"
    # tokens.each do |t|
    #   puts t.inspect
    # end

    do_parse
  end

  def on_error(t, val, vstack)
    puts t
    puts val
    puts vstack
    super
  end

  def initialize
    super
    @variables = {}
  end
