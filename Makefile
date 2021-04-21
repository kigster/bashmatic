# vim: tabstop=8
# vim: shiftwidth=8
# vim: noexpandtab

# grep '^[a-z\-]*:' Makefile | cut -d: -f 1 | tr '\n' ' '
.PHONY:	 help install fonts-setup fonts-clean update-changelog update-functions update-usage update-readme regenerate-readme reduce-size-readme open-readme git-add update setup test docker-build docker-run docker-run-bash docker-run-zsh docker-run-fish file-stats-git file-stats-local shell-files

red             		:= \033[0;31m
bold             		:= \033[1;45m
yellow          		:= \033[0;33m
blue            		:= \033[0;34m
green           		:= \033[0;35m
clear           		:= \033[0m

RUBY_VERSION    		:= $(cat .ruby-version)
OS	 		 	:= $(shell uname -s | tr '[:upper:]' '[:lower:]')

# see: https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile/18137056#18137056
SCREEN_WIDTH			:= 100
MAKEFILE_PATH 			:= $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR 			:= $(notdir $(patsubst %/,%,$(dir $(MAKEFILE_PATH))))

# BASHMATIC VARIABLES
BASHMATIC_HOME			:= $(shell dirname $(MAKEFILE_PATH))
BASHMATIC_VERSION		:= $(shell cat .version)
BASHMATIC_TAG			:= "v$(BASHMATIC_VERSION)"
BASHMATIC_RELEASE		:= "Release for Tag $(BASHMATIC_TAG)"


help:	   			## Prints help message auto-generated from the comments.
				@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

docker-build:			## Builds the Docker image with the tooling inside
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Building a Docker Image...$(clear)\n"
				@docker build -t bashmatic:latest .

docker-run: 			docker-run-bash ## Drops you into a BASH session

docker-run-bash:     		docker-build ## Drops you into a BASH session with Bashmatic Loaded
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Attempting to start a Docker Image $(yellow)bashmatic:latest...$(clear)\n"
				@docker run -it --entrypoint=/bin/bash bashmatic:latest -l
 
docker-run-zsh:     		docker-build ## Drops you into a ZSH session with Bashmatic Loaded
				@docker run -it --entrypoint=/bin/zsh bashmatic:latest -l

docker-run-fish:    		docker-build ## Drops you into a FISH session with Bashmatic Loaded
				docker run -it --entrypoint=/bin/fish bashmatic:latest -l

install:			## install BashMatic Locally in ~/.bashmatic
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Running bin/bashmatic-installer script..$(clear)\n"
				@$(BASHMATIC_HOME)/bin/bashmatic-install

fonts-setup:			
				@bash -c 'tar xzf .fonts.tar.gz'

fonts-clean:			
				@bash -c 'rm -rf .fonts'
			

file-stats-local:		## Print all non-test files and run `file` utility on them.
				@find . -type f \! -ipath '*\.git*' -and  ! -ipath '*\.bundle*' -and ! -ipath '*\.bats*' | sed  's/^\.\///g' | xargs file

shell-files:			## Lists every single checked in SHELL file in this repo
				@find . -type f \! -ipath '*\.git*' -and  ! -ipath '*\.bundle*' -and ! -ipath '*\.bats*' | sed  's/^\.\///g' | xargs file | grep  Bourne | awk '{print $1}'

make-utf8:			## Convert all text SHELL script  files from ASCII to UTF8 format
				@bash -c "
					function to-utf8() {
						FROM_ENCODING="$1"
					TO_ENCODING="UTF-8"
					CONVERT="iconv  -f  $FROM_ENCODING  -t  $TO_ENCODING"
				#loop to convert multiple files 
				for  file  in  *.txt; do
				     $CONVERT   "$file"   -o  "${file%.txt}.utf8.converted"
				done
				exit 0

file-stats-git:			## Print all  files  known to `git ls-files` command
				@git ls-files | xargs files

#—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

update: 			update-changelog update-functions update-usage update-readme fonts-clean git-add ## Runs all of the updates, add locally modiofied files to git.

update-changelog: 		## Auto-generate the doc/CHANGELOG (requires GITHUB_TOKEN env var set)
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Regenerating CHANGELOG....$(clear)\n"
				@bash -c "$(BASHMATIC_HOME)/bin/regen-changelog"
				@mv $(BASHMATIC_HOME)/CHANGELOG.md $(BASHMATIC_HOME)/doc

update-functions: 		## Auto-generate doc/FUNCTIONS index at doc/FUNCTIONS.adoc/pdf
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Regenerating doc/FUNCTIONS.adoc — functions INDEX...$(clear)\n"
				@bash -c "source $(BASHMATIC_HOME)/bin/regen-index-docs; generate-functions-index"

update-usage: 			fonts-setup ## Auto-generate doc/USAGE documentation from lib shell files, to doc/USAGE.adoc/pdf
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Running bin/regen-usage-docs command...$(clear)\n"
				@bin/regen-usage-docs

update-readme:			fonts-setup regenerate-readme fonts-clean open-readme ## Re-generate the PDF version of the README

regenerate-readme:		fonts-setup
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Converting README.adoc into the PDF...$(clear)\n"
				@[[ -s README.adoc ]] && $(BASHMATIC_HOME)/bin/adoc2pdf README.adoc
					
reduce-size-readme:
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Reducing the PDF Size.... $(clear)\n"
				@$(BASHMATIC_HOME)/bin/pdf-reduce README.pdf README.pdf.reduced
				@[[ -s README.pdf.reduced ]] && mv -v README.pdf.reduced README.pdf

open-readme:			## Open README.pdf in the system viewer
				@[[ -s README.pdf ]] && open -n README.pdf

#—————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
git-add:
				@printf "\n$(bold)  👉  $(yellow)Git status after the update:$(clear)\n"
				@git add .
				@printf "\n$(bold)  👉  $(blue)Git status after the update:$(clear)\n"
				@git status


setup: 				## Run the comprehensive development setup on this machine
				@printf "\n$(bold)  👉    $(red)$(clear)  $(green)Running developer setup script, this may take a while.$(clear)\n"
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
			
test: 				## Run fully automated test suite based on Bats
				@$(BASHMATIC_HOME)/bin/specs

test-parallel: 			## Run the fully auto-g mated test suite
				@$(BASHMATIC_HOME)/bin/specs -p

test-install-quiet:		
				@bash -c "cd $(BASHMATIC_HOME); source bin/bashmatic-install; bashmatic-install -q"
	
test-install-verbose:		
				@bash -c "cd $(BASHMATIC_HOME); source bin/bashmatic-install; bashmatic-install -v"

				## Task invoked by VSCode when right-clicking the test directory
test-integration: 		test-parallel

tag:				## Tag this commit with .version and push to remote
				@git tag $(BASHMATIC_TAG) -f
				@git push --tags -f

release: tag 			## Make a new release named after the latest tag
				@command -v gh>/dev/null || brew install gh
				@gh release create $(BASHMATIC_TAG) . --title "$(BASHMATIC_RELEASE)"
