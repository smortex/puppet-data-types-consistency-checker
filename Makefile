COMPILED_TEMPLATES=	epp_parser.tab.rb  pp_parser.tab.rb template_parser.tab.rb

all: ${COMPILED_TEMPLATES}
	
.SUFFIXES: .y .tab.rb

.y.tab.rb:
	bundle exec racc ${.IMPSRC}

clean:
	rm -f ${COMPILED_TEMPLATES}
