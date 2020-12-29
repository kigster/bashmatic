# vim: tabstop=8
# vim: shiftwidth=8
# vim: noexpandtab

.PHONY:	 help install update_changelog update_function update_shdoc 

red             		:= \033[0;31m
yellow          		:= \033[0;33m
blue            		:= \033[0;34m
green           		:= \033[0;35m
clear           		:= \033[0m

RUBY_VERSION    		:= $(cat .ruby-version)
OS	 		 	:= $(shell uname -s | tr '[:upper:]' '[:lower:]')

# see: https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile/18137056#18137056
MAKEFILE_PATH 			:= $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR 			:= $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))
BASHMATIC_HOME			:= $(shell dirname $(MAKEFILE_PATH))

help:	   			## Prints help message auto-generated from the comments.
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install:			## install BashMatic Locally in ~/.bashmatic
				@printf " 👉  $(green)Running bin/bashmatic-installer script..$(clear)\n"
				@$(BASHMATIC_HOME)/bin/bashmatic-install

update_changelog: 		## Auto-generate the doc/CHANGELOG (requires GITHUB_TOKEN env var set)
				@printf " 👉  $(green)Regenerating doc/CHANGELOG....$(clear)\n"
				@bash -c "source ${BASHMATIC_HOME}/bin/regen-index-docs; generate-changelog"

update_functions: 		## Auto-generate doc/FUNCTIONS index at doc/FUNCTIONS.adoc/pdf
				@printf " 👉  $(green)Regenerating doc/FUNCTIONS.adoc — functions INDEX...$(clear)\n"
				@bash -c "source ${BASHMATIC_HOME}/bin/regen-index-docs; generate-functions-index"

update_usage: 			## Auto-generate doc/USAGE documentation from lib shell files, to doc/USAGE.adoc/pdf
				@printf " 👉  $(green)Extracting shdoc documentation from library shell files ....$(clear)\n"
				@bash -c "source ${BASHMATIC_HOME}/init.sh && shdoc.install"
				@bash -c "source ${BASHMATIC_HOME}/bin/regen-index-docs; gem.install asciidoctor; generate-shdoc"

				@printf " 👉  $(green)Converting USAGE.md into the ASCIIDOC...$(clear)\n"
				@[[ -s doc/USAGE.md ]] && kramdoc doc/USAGE.md

				@printf " 👉  $(green)Converting USAGE.adoc into the PDF...$(clear)\n"
				@[[ -s doc/USAGE.adoc ]] && ${BASHMATIC_HOME}/bin/adoc2pdf doc/USAGE.adoc

				@printf " 👉  $(green)Reducing the PDF Size.... $(clear)\n"
				@$(BASHMATIC_HOME)/bin/pdf-reduce doc/USAGE.pdf USAGE.pdf.reduced
			    	@[[ -s USAGE.pdf.reduced ]] && mv -v USAGE.pdf.reduced doc/USAGE.pdf

update_readme:			## Re-generate the PDF version of the README
				@printf " 👉  $(green)Converting README.adoc into the PDF...$(clear)\n"
				@[[ -s README.adoc ]] && ${BASHMATIC_HOME}/bin/adoc2pdf README.adoc

				@printf " 👉  $(green)Reducing the PDF Size.... $(clear)\n"
				@$(BASHMATIC_HOME)/bin/pdf-reduce README.pdf README.pdf.reduced
				@[[ -s README.pdf.reduced ]] && mv -v README.pdf.reduced README.pdf

update: update_changelog update_functions update_usage update_readme ## Runs all of the updates, add locally modiofied files to git.

				@printf " 👉  $(yellow)Git status after the update:$(clear)\n"
				@git add .
				@printf " 👉  $(blue)Git status after the update:$(clear)\n"
				@git status


setup: 				## Run the comprehensive development setup on this machine
				@printf " 👉  $(green)Running developer setup script, this may take a while.$(clear)\n"
				@$(BASHMATIC_HOME)/bin/dev-setup -r $(RUBY_VERSION) \
					-g dev \
					-g cpp \
					-g fonts  \
					-g gnu  \
					-g go  \
					-g java  \
					-g js  \
					-g load-balancing   \
					-g postgres    \
					-g ruby
			
test: 				## Run the fully auto-g mated test suite
				@$(BASHMATIC_HOME)/bin/specs



