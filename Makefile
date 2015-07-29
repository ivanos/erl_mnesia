APPS = kernel stdlib sasl erts ssl tools runtime_tools crypto inets \
	public_key mnesia syntax_tools compiler
COMBO_PLT = $(HOME)/.erl_mnesia_combo_dialyzer_plt

.PHONY: all compile test clean ct

all: compile

compile:
	./rebar compile

eunit: compile
	./rebar -v skip_deps=true eunit

ct: compile
	./rebar -v ct $(CTARGS)

clean:
	./rebar clean

build_plt: compile
	dialyzer --build_plt --output_plt $(COMBO_PLT) --apps $(APPS)

check_plt: compile
	dialyzer --check_plt --plt $(COMBO_PLT) --apps $(APPS)

dialyzer: compile
	@echo
	@echo Use "'make check_plt'" to check PLT prior to using this target.
	@echo Use "'make build_plt'" to build PLT prior to using this target.
	@echo
	dialyzer --plt $(COMBO_PLT) ebin

compile test clean: rebar

rebar:
	wget -c http://github.com/rebar/rebar/wiki/rebar
	chmod +x $@
