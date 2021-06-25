# kudos:
#   - https://medium.com/@exustash/three-good-practices-for-better-ci-cd-makefiles-5b93452e4cc3
#   - https://le-gall.bzh/post/makefile-based-ci-chain-for-go/
#   - https://makefiletutorial.com/
#   - https://www.cl.cam.ac.uk/teaching/0910/UnixTools/make.pdf
#
SHELL := /usr/bin/env bash # set default shell
.SHELLFLAGS = -c # Run commands in a -c flag 

.NOTPARALLEL: ;          # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell

.PHONY: all # All targets are accessible for user
.DEFAULT: help # Running Make will run the help target

BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
ifeq ($(BRANCH), HEAD)
	BRANCH := ${CI_BUILD_REF_NAME}
endif

# help: @ List available tasks of the project
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

## test section
# All tests are called on "." if possible.
# If this is not possible a special loop is used
# to sum up all error codes.

# test: @ Run all defined tests
test: test-codespell test-shellcheck test-yamllint test-jsonlint test-salt-lint test-terraform-format test-terraform-validation
	@echo "All tests Done!"

# test-codespell: @ Run spell check
test-codespell:
	codespell -H -f -s -I .codespell.ignore.words -S $(shell cat .codespell.ignore.files) -C 4 -q 6

# test-shellcheck: @ Run linting on all shell scripts
test-shellcheck:
	for file in $(shell find . -name '*.sh' ! -path "**/venv/*"); do\
		echo $${file} ;\
		shellcheck -s bash -x $${file};\
		err=$$(($$? + err)) ;\
	done; exit $$err

# test-yamllint: @ Run linting on all yaml files
test-yamllint:
	# yamllint -c .yamllint.yaml -s .
	yamllint -c .yamllint.yaml .

# test-jsonlint: @ Run linting on all json files
test-jsonlint:
	for file in $(shell find . -name '*.json' ! -path "**/venv/*"); do\
		echo $${file} ;\
		jq << $${file} >/dev/null;\
		err=$$(($$? + err)) ;\
	done; exit $$err

# test-salt-lint: @ Run linting on all salt files
test-salt-lint:
	for file in $(shell find salt/ -name '*.sls'); do\
		echo $${file} ;\
		salt-lint $${file};\
		err=$$(($$? + err)) ;\
	done; exit $$err

# test-terraform-format: @ Run format check on all terraform files
test-terraform-format:
	for cloud_provider in aws azure gcp libvirt openstack ; do\
	    cd $${cloud_provider} >/dev/null ;\
	    echo $${cloud_provider} ;\
	    terraform fmt -check=true -diff=true ;\
	    err=$$(($$? + err)) ;\
	    cd - >/dev/null ;\
	done; exit $$err

# test-terraform-validation: @ Run validation check on all terraform files
test-terraform-validation:
	for cloud_provider in aws azure gcp libvirt openstack ; do\
	    cd $${cloud_provider} >/dev/null ;\
	    echo $${cloud_provider} ;\
	    terraform init 2>&1 >/dev/null;\
	    terraform validate ;\
	    err=$$(($$? + err)) ;\
	    cd - >/dev/null ;\
	done; exit $$err

# TODO: evaluate if this can be run without actual credentials
# test-terraform-plan: @ Run terraform in "plan mode" on all terraform cloud providers (disabled by default)
test-terraform-plan:
	for cloud_provider in aws azure gcp libvirt openstack ; do\
	    cd $${cloud_provider} >/dev/null ;\
	    echo $${cloud_provider} ;\
	    terraform init 2>&1 >/dev/null;\
	    terraform plan -var-file=./terraform.tfvars.example -var-file=../.ci/terraform.tfvars.ci ;\
	    err=$$(($$? + err)) ;\
	    cd - >/dev/null ;\
	done; exit $$err

# all: @ Runs everything
all: test
