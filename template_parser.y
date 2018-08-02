class TemplateParser
rule
  target: statements
  
  statements: statements statement
            | statement

  statement: EPP { e = EppParser.new; e.parse(val[0]); @variables.merge!(e.variables) }
           | TEXT

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
    when s.scan(/<%%/);      tokens << [:TEXT, s.matched]
    when s.scan(/<%.*?%>/m); tokens << [:EPP, s.matched]
    when s.scan(/[^<]+/m);   tokens << [:TEXT, s.matched]
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
