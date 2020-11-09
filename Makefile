all:
	@rebar3 compile

clean:
	@echo "Removing files ..."
	@rm -v src/{dot_lexer,dot_parser}.erl

test:
	@rebar3 eunit
