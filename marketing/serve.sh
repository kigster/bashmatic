#!/usr/bin/env bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

function print_header() {
  echo -e "${BLUE}==============================================${RESET}"
  echo -e "${GREEN}   Bashmatic Marketing Site Local Server    ${RESET}"
  echo -e "${BLUE}==============================================${RESET}"
  echo ""
}

function print_url() {
  local port="$1"
  echo -e "${GREEN}Server started!${RESET}"
  echo -e "${YELLOW}Access the site at:${RESET} ${BLUE}http://localhost:${port}${RESET}"
  echo ""
  echo -e "${YELLOW}Press Ctrl+C to stop the server.${RESET}"
}

function use_python3() {
  local port=8000
  echo -e "${GREEN}Using Python 3 to serve the site...${RESET}"
  print_url "$port"
  python3 -m http.server "$port"
}

function use_python2() {
  local port=8000
  echo -e "${GREEN}Using Python 2 to serve the site...${RESET}"
  print_url "$port"
  python -m SimpleHTTPServer "$port"
}

function use_node() {
  local port=8080
  echo -e "${GREEN}Using Node.js http-server to serve the site...${RESET}"
  
  if ! command -v http-server >/dev/null 2>&1; then
    echo -e "${YELLOW}http-server not found. Installing it globally...${RESET}"
    npm install -g http-server
  fi
  
  print_url "$port"
  http-server -p "$port"
}

function use_php() {
  local port=8000
  echo -e "${GREEN}Using PHP built-in server to serve the site...${RESET}"
  print_url "$port"
  php -S "localhost:$port"
}

function use_ruby() {
  local port=8000
  echo -e "${GREEN}Using Ruby to serve the site...${RESET}"
  
  if ! command -v ruby >/dev/null 2>&1; then
    echo -e "${RED}Ruby not found.${RESET}"
    return 1
  fi
  
  if ! gem list -i webrick >/dev/null 2>&1; then
    echo -e "${YELLOW}Webrick gem not found. Installing...${RESET}"
    gem install webrick
  fi
  
  print_url "$port"
  ruby -rwebrick -e "WEBrick::HTTPServer.new(:Port => $port, :DocumentRoot => Dir.pwd).start"
}

print_header

# Try different methods in order of preference
if command -v python3 >/dev/null 2>&1; then
  use_python3
elif command -v node >/dev/null 2>&1; then
  use_node
elif command -v python >/dev/null 2>&1; then
  # Verify it's Python 2
  python_version=$(python -c "import sys; print(sys.version_info[0])")
  if [ "$python_version" = "2" ]; then
    use_python2
  else
    use_python3  # It's Python 3 with "python" command
  fi
elif command -v php >/dev/null 2>&1; then
  use_php
elif command -v ruby >/dev/null 2>&1; then
  use_ruby
else
  echo -e "${RED}Error: Could not find any suitable program to serve the site.${RESET}"
  echo -e "${YELLOW}Please install one of: Python, Node.js, PHP, or Ruby.${RESET}"
  exit 1
fi 