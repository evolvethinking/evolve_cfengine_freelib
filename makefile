CF_PROMISES = cf-promises
CF_AGENT    = cf-agent
VERSION     = 3.6
LIB         = lib/$(VERSION)
EFL_LIB     = masterfiles/$(LIB)/EFL
CF_REPO     = https://github.com/cfengine
CSVTOJSON   = ./bin/csvtojson

EFL_FILES   = \
	$(EFL_LIB)/efl_common.cf \
	$(EFL_LIB)/evolve_freelib.cf

eflmaker    = ./bin/eflmaker
cfstdlib    = \
	test/$(LIB)/commands.cf \
	test/$(LIB)/processes.cf \
	test/$(LIB)/feature.cf \
	test/$(LIB)/vcs.cf \
	test/$(LIB)/cfe_internal.cf \
	test/$(LIB)/reports.cf \
	test/$(LIB)/guest_environments.cf \
	test/$(LIB)/bundles.cf \
	test/$(LIB)/services.cf \
	test/$(LIB)/common.cf \
	test/$(LIB)/users.cf \
	test/$(LIB)/storage.cf \
	test/$(LIB)/packages.cf \
	test/$(LIB)/paths.cf \
	test/$(LIB)/files.cf \
	test/$(LIB)/databases.cf \
	test/$(LIB)/edit_xml.cf \
	test/$(LIB)/examples.cf \
	test/$(LIB)/monitor.cf \
	test/$(LIB)/stdlib.cf

tests       =    \
	version       \
	syntax        \
	001_efl_test  \
	002_efl_test  \
	003_efl_test  \
	004_efl_test  \
	005_efl_test  \
	006_efl_test  \
	007_efl_test  \
	008_efl_test \
	009_efl_test \
	010_efl_test \
	011_efl_test \
	012_efl_test \
	013_efl_test \
	014_efl_test \
	015_efl_test \
	016_efl_test \
	017_efl_test \
	018_efl_test \
	019_efl_test \
	020_efl_test

# $(call cf_agent_grep_test ,target_class,result_string)
define cf_agent_grep_test 
 	cd test/masterfiles; $(CF_AGENT) -Kf ./promises.cf -D $1 | \
	perl -e '                            \
	while (<STDIN>) { $$OUTPUT .= $$_  } \
		if ( $$OUTPUT =~ m|\A$2\Z| )      \
			{ print "PASS: $@\n" }         \
		else                              \
			{ die "FAIL: $@" }'
endef

# $(call search_and_replace,search_regex replace_string target_file)
define search_and_replace
	perl -pi -e 's/$1/$2/' $3
endef
	
define test_sysctl_live
	/sbin/sysctl vm.swappiness='67'
	cd test/masterfiles; cf-agent -Kf ./promises.cf -D $(1)_efl_test
	cd test/serverspec; rspec spec/localhost/019_efl_test_spec.rb
	/sbin/sysctl vm.swappiness='60'
endef

.PHONY: all
all: $(EFL_FILES)

$(EFL_FILES): $(EFL_LIB) src/includes/param_parser.cf src/includes/param_file_picker.cf src/$@
	cp src/$@ $@
	$(eflmaker) --tar $@ \
		--tag param_parser -i src/includes/param_parser.cf
	$(eflmaker) --tar $@ \
		--tag param_file_picker -i src/includes/param_file_picker.cf

$(EFL_LIB):
	mkdir -p $@

.PHONY: check
check: test/$(EFL_LIB) $(cfstdlib) $(EFL_FILES) $(tests)
	@echo PASSED ALL TESTS

test/$(EFL_LIB):
	mkdir -p $@
	cp -r $(EFL_LIB)/* test/$(EFL_LIB)/

$(cfstdlib): .stdlib

.stdlib:
	cd test/masterfiles/lib; svn export --force $(CF_REPO)/masterfiles/trunk/lib/$(VERSION)
	touch $@

.PHONY: version
version:
	$(CF_PROMISES) -V | grep $(VERSION) && echo PASS: $@

.PHONY: syntax
syntax:
	OUTPUT=$$($(CF_PROMISES) -cf ./test/masterfiles/promises.cf 2>&1) ;\
	if [ -z "$$OUTPUT" ] ;\
	then                  \
		echo PASS: $@     ;\
	else                  \
		echo FAIL: $@     ;\
		echo $$OUTPUT     ;\
		exit 1            ;\
	fi                    

001_002_efl_test_result = R: PASS, any, efl_main order 1\nR: PASS, any, efl_main order 2\nR: PASS, any, efl_main order 3\nR: PASS, any, efl_main order 4\nR: PASS, any, efl_main order 5
.PHONY: 002_efl_test
001_csv_test_files  = $(wildcard test/001/*.csv)
002_csv_test_files  = $(patsubst test/001%,test/002%,$(001_csv_test_files))
002_json_test_files = $(patsubst %.csv,%.json,$(002_csv_test_files))
002_efl_test: 001_efl_test test/002/efl_main.json $(002_json_test_files)
	$(call cf_agent_grep_test, $@,$(001_002_efl_test_result))

test/002/efl_main.json: test/001/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,001,002,$@) 
	$(call search_and_replace,\.csv,\.json,$@) 

test/002/%_efl_test_simple.json: test/001/%_efl_test_simple.csv
	echo 002_json_test_files $@
	$(CSVTOJSON) -b efl_test_simple < $^ > $@

.PHONY: 001_efl_test
001_efl_test: 
	$(call cf_agent_grep_test, $@,$(001_002_efl_test_result))

.PHONY: 004_efl_test
004_efl_test_result = R: PASS, 004_true_true, Class if /bin/true\nR: PASS, 004_true_false, Class if /bin/false\nR: PASS, 004_false_false, Is not true
004_efl_test: 003_efl_test test/004/efl_main.json test/004/01_efl_returnszero.json test/004/02_efl_test_simple.json
	$(call cf_agent_grep_test, $@,$(004_efl_test_result))

test/004/efl_main.json: test/003/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,003,004,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/004/01_efl_returnszero.json: test/003/01_efl_returnszero.csv
	$(CSVTOJSON) -b efl_class_returnszero < $^ > $@
	$(call search_and_replace,003,004,$@) 

test/004/02_efl_test_simple.json: test/003/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,003,004,$@) 

.PHONY: 003_efl_test
003_efl_test_result = R: PASS, 003_true_true, Class if /bin/true\nR: PASS, 003_true_false, Class if /bin/false\nR: PASS, 003_false_false, Is not true
003_efl_test:
	$(call cf_agent_grep_test, $@,$(003_efl_test_result))

005_006_efl_test_result = R: efl_global_lists\.ntp_servers  => \[ntp1\.example\.com\]\nR: efl_global_lists\.ntp_servers  => \[ntp2\.example\.com\]\nR: efl_global_lists\.ntp_servers  => \[ntp3\.example\.com\]\n(R: efl_global_lists\.name_servers => \[10\.0\.0\.\d{1}\]\n){3}(R: efl_global_lists\.web_servers  => \[\d{1}\.example\.com\]\n{0,1}){3}
.PHONY: 006_efl_test
006_efl_test:  005_efl_test test/006/efl_main.json test/006/01_efl_global_slists.json test/006/02_efl_dump_strings.json test/006/name_servers.txt
	$(call cf_agent_grep_test, $@,$(005_006_efl_test_result))

test/006/efl_main.json: test/005/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,005,006,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/006/01_efl_global_slists.json: test/005/01_efl_global_slists.csv
	$(CSVTOJSON) -b efl_global_slists < $^ > $@
	$(call search_and_replace,005,006,$@) 

test/006/02_efl_dump_strings.json: test/005/02_efl_dump_strings.csv
	$(CSVTOJSON) -b efl_dump_strings < $^ > $@
	$(call search_and_replace,005,006,$@) 

test/006/name_servers.txt: test/005/name_servers.txt
	cp test/005/name_servers.txt test/006/

.PHONY: 005_efl_test
005_efl_test:
	$(call cf_agent_grep_test, $@,$(005_006_efl_test_result))

007_008_efl_test_result = R: Name => \[efl_global_strings\.main_efl_dev\] Value => \[Neil H\. Watson \(neil\@watson-wilson\.ca\)\] Promisee => \[efl_development\]\nR: Name => \[efl_global_strings\.gateway\] Value => \[2001:DB8::1\] Promisee => \[efl_development\]
.PHONY: 008_efl_test
008_efl_test:  007_efl_test test/008/efl_main.json test/008/01_efl_global_strings.json test/008/02_efl_dump_strings.json
	$(call cf_agent_grep_test, $@,$(007_008_efl_test_result))

test/008/efl_main.json: test/007/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,007,008,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/008/01_efl_global_strings.json: test/007/01_efl_global_strings.csv
	$(CSVTOJSON) -b efl_global_strings < $^ > $@
	$(call search_and_replace,007,008,$@) 

test/008/02_efl_dump_strings.json: test/007/02_efl_dump_strings.csv
	$(CSVTOJSON) -b efl_dump_strings < $^ > $@
	$(call search_and_replace,007,008,$@) 

.PHONY: 007_efl_test
007_efl_test:
	$(call cf_agent_grep_test, $@,$(007_008_efl_test_result))

.PHONY: 010_efl_test
010_efl_test: 010_efl_test_result = R: PASS, 010_test_class_01, true if output matches\nR: PASS, 010_test_class_02, true if output does not match\nR: PASS, 010_test_class_03, should not match\nR: PASS, 010_test_class_04, true if output is there

010_efl_test: 009_efl_test test/010/01_efl_class_cmd_regcmp.json test/010/02_efl_test_simple.json test/010/efl_main.json
	$(call cf_agent_grep_test, $@,$(010_efl_test_result))

test/010/efl_main.json: test/009/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,009,010,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/010/01_efl_class_cmd_regcmp.json: test/009/01_efl_class_cmd_regcmp.csv
	$(CSVTOJSON) -b efl_class_cmd_regcmp < $^ > $@
	$(call search_and_replace,009,010,$@) 

test/010/02_efl_test_simple.json: test/009/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,009,010,$@) 

009_efl_test: 009_efl_test_result = R: PASS, 009_test_class_01, true if output matches\nR: PASS, 009_test_class_02, true if output does not match\nR: PASS, 009_test_class_03, should not match\nR: PASS, 009_test_class_04, true if output is there
009_efl_test:
	$(call cf_agent_grep_test, $@,$(009_efl_test_result))

.PHONY: 012_efl_test
012_efl_test: 012_efl_test_result = R: PASS, 012_test_class_01, pass if both classes match\nR: PASS, 012_test_class_02, pass if either class matches\nR: PASS, 012_test_class_03, pass if neither class matches

012_efl_test: 011_efl_test test/012/01_efl_class_expression.json test/012/02_efl_test_simple.json test/012/efl_main.json
	$(call cf_agent_grep_test, $@,$(012_efl_test_result))

test/012/efl_main.json: test/011/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,011,012,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/012/01_efl_class_expression.json: test/011/01_efl_class_expression.csv
	$(CSVTOJSON) -b efl_class_expression < $^ > $@
	$(call search_and_replace,011,012,$@) 

test/012/02_efl_test_simple.json: test/011/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,011,012,$@) 

.PHONY: 011_efl_test
011_efl_test: 011_efl_test_result = R: PASS, 011_test_class_01, pass if both classes match\nR: PASS, 011_test_class_02, pass if either class matches\nR: PASS, 011_test_class_03, pass if neither class matches
011_efl_test:
	$(call cf_agent_grep_test, $@,$(011_efl_test_result))

.PHONY: 014_efl_test
014_efl_test: 014_efl_test_result = R: PASS, 014_test_class_01, pass\nR: PASS, 014_test_class_02, pass\nR: PASS, 014_test_class_03, pass if class never matches
014_efl_test: 013_efl_test test/014/01_efl_class_classmatch.json test/014/02_efl_test_simple.json test/014/efl_main.json
	$(call cf_agent_grep_test, $@,$(014_efl_test_result))

test/014/efl_main.json: test/013/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,013,014,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/014/01_efl_class_classmatch.json: test/013/01_efl_class_classmatch.csv
	$(CSVTOJSON) -b efl_class_classmatch< $^ > $@
	$(call search_and_replace,013,014,$@) 

test/014/02_efl_test_simple.json: test/013/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,013,014,$@) 

.PHONY: 013_efl_test
013_efl_test: 013_efl_test_result = R: PASS, 013_test_class_01, pass\nR: PASS, 013_test_class_02, pass\nR: PASS, 013_test_class_03, pass if class never matches
013_efl_test:
	$(call cf_agent_grep_test, $@,$(013_efl_test_result))

.PHONY: 016_efl_test
016_efl_test: 016_efl_test_result = R: PASS, 016_test_class_01, pass ipv4\nR: PASS, 016_test_class_03, pass if class never matches
# For when ipv6 support in iprange is available: https://dev.cfengine.com/issues/6875
#016_efl_test: 016_efl_test_result = R: PASS, 016_test_class_01, pass ipv4\nR: PASS, 016_test_class_02, pass ipv6\nR: PASS, 016_test_class_03, pass if class never matches
016_efl_test: 015_efl_test test/016/01_efl_class_iprange.json test/016/02_efl_test_simple.json test/016/efl_main.json
	$(call cf_agent_grep_test, $@,$(016_efl_test_result))

test/016/efl_main.json: test/015/efl_main.csv
	$(CSVTOJSON) -b efl_main < $< > $@
	$(call search_and_replace,015,016,$@) 
	$(call search_and_replace,\.csv,\.json,$@)

test/016/01_efl_class_iprange.json: test/015/01_efl_class_iprange.csv
	$(CSVTOJSON) -b efl_class_iprange< $^ > $@
	$(call search_and_replace,015,016,$@) 

test/016/02_efl_test_simple.json: test/015/02_efl_test_simple.csv
	$(CSVTOJSON) -b efl_test_simple < $^ > $@
	$(call search_and_replace,015,016,$@) 

.PHONY: 015_efl_test
015_efl_test: 015_efl_test_result = R: PASS, 015_test_class_01, pass ipv4\nR: PASS, 015_test_class_03, pass if class never matches
# For when ipv6 support in iprange is available: https://dev.cfengine.com/issues/6875
#015_efl_test: 015_efl_test_result = R: PASS, 015_test_class_01, pass ipv4\nR: PASS, 015_test_class_02, pass ipv6\nR: PASS, 015_test_class_03, pass if class never matches
015_efl_test:
	$(call cf_agent_grep_test, $@,$(015_efl_test_result))

.PHONY: 017_efl_test
017_efl_test: 017_efl_test_result = R: PASS, 017_test_class, pass efl_class_hostname\nR: PASS, never, pass if never defined
017_efl_test:
	$(call cf_agent_grep_test, $@,$(017_efl_test_result))

.PHONY: 018_efl_test
018_efl_test: 018_efl_test_result = R: PASS, 018_test_class_01, pass efl_class_hostname2 01\nR: PASS, 018_test_class_02, pass efl_class_hostname2 02\nR: PASS, never, pass if never defined
018_efl_test:
	$(call cf_agent_grep_test, $@,$(018_efl_test_result))

.PHONY: 020_efl_test
020_efl_test: 019_efl_test test/020/01_efl_sysctl_live.json
	$(call test_sysctl_live,020)

test/020/01_efl_sysctl_live.json: test/019/01_efl_sysctl_live.csv
	$(CSVTOJSON) -b efl_sysctl_live < $^ > $@
	$(call search_and_replace,019,020,$@) 

.PHONY: 019_efl_test
019_efl_test:
	$(call test_sysctl_live,019)

.PHONY: clean
clean:
	rm -fr masterfiles/*
	rm -f .stdlib
	rm -fr test/$(EFL_LIB)

.PHONY: help
help:
	$(MAKE) --print-data-base --question |           \
		awk '/^[^.%][-A-Za-z0-9_]*:/                  \
			{ print substr($$q, 1, length($$1)-1) }' | \
		sort |                                        \
		pr --omit-pagination --width=80 --columns=4
