.PHONY: \
	all \
	deps \
	deps_get \
	deps_update \
	compile_app \
	compile_all \
	test \
	test_all \
	clean \
	clean_all \
	dialyze


all: \
	clean_all \
	deps \
	compile_all \
	test \
	dialyze

deps: \
	deps_get \
	deps_update

deps_get:
	@rebar get-deps

deps_update:
	@rebar update-deps

compile_app:
	@rebar compile skip_deps=true

compile_all:
	@rebar compile skip_deps=false

test:
	@rebar ct skip_deps=true --verbose=0

test_all:
	@rebar ct skip_deps=false --verbose=0

clean:
	@rebar clean skip_deps=true
	@rm -rf ebin/

clean_all:
	@rebar clean skip_deps=false
	@rm -rf ebin/

dialyze:
	@dialyzer \
		$(shell \
			find ./ebin ./deps -name '*.beam' \
		)
