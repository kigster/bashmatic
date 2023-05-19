#!/usr/bin/env bash
# @description Renames files matching the input parameters to `find` by
# replacing spaces with dashes and lower casing the file.
function files.normalize-tree() {
  local command="__files.normalize-tree"
  ( "${command}" "$@" ) 
}

function __files.normalize-tree() {
  local dry_run=false
  local verbose=false
  local interactive=false
  local -a delete_files=( .DS_Store )
  local -a skip_files=( Icon Icon$(echo -e "\r") )
  local -a find_args
  find_args=()

  while :; do
    [[ -z $1 ]] && break
    case $1 in
      --dry-run|-n)
        dry_run=true
        shift
        ;;
      --verbose|-v)
        verbose=true
        shift
        ;;
      --interactive|-i)
        interactive=true
        shift
        ;;
      --help|-h)
        printf "${bldgrn}USAGE:${bldylw}
        files.normalize-tree [ --verbose | -v ] [ --dry-run | -n ] 
                             [ --interactive | -i ] 
                             < additional find arguments to find command>

${bldgrn}DESCRIPTION:
        ${clr}Given the search pattern to find, this function will rename all of the
        files matching find parameteres (relative to the current directory) 
        to a lower case and replace spaces with dashes.\n\n" 
        return
        ;;
      *)
        find_args+=( "$1" )
        shift
        ;;
    esac
  done

  local find_command
  if [[ ${find_args[*]} =~ find ]] ; then
    find_command="${find_args[*]}"
  else
    find_command="find . -type f ${find_args[*]}"
  fi

  info "Files will be searched using the following command:"
  h1 " ❯ ${bldylw}${find_command}"

  local -a files
  mapfile -t files < <(eval "${find_command}")
  if [[ ${#files[@]} -eq 0 ]]; then
    error "No files mathed search pattern [$*]" \
      "Please make sure that you escape any single quotes, like so:" \
      "files.normalize-tree -spaces [ --dry-run ] -name \'*.wav\'"
    return 1
  else 
    h4 "Total of ${#files[@]} files matched."
  fi

  ${interactive} && run.ui.ask "Should I proceed with the rename?"
  
  local show_warning=true
  run.set-all abort-on-error show-output-on
  for file in "${files[@]}"; do   
    ${verbose} && printf "processing file ${bldgrn}%s${clr}\n" "${file}" 
    [[ -f "${file}" ]] || continue
    local command
    local file_basename="$(basename "${file}")"
    if array.includes "${skip_files[@]}" "${file_basename}"; then
      info "File matched one of the skip files, skipping."
      continue
    elif array.includes "${delete_files[@]}" "${file_basename}"; then
      info "File matched one of the delete files, deleting ."
      command="rm -fv ${file}"
    else
      local f="$(echo "${file}" | tr -d '\n')";  
      local newname="$(echo -e "${f}" | ascii-pipe  | tr ' ' '-' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]' | tr -d '\r\n')";
      local dir="$(dirname "${newname}")"
      command="[[ -d \"${dir}\" ]] || mkdir -p \"${dir}\"; mv -vi \"${file}\" \"${newname}\""
    fi

    ${dry_run} && { 
      info "[dry-run] ❯ ${bldylw}${command}"
      continue
    }
    
    if ${interactive} ; then
      local answer
      ${show_warning} && {
        h3bg "NOTE: if you answer 'a' or 'all' to any of the following questions" \
                "the rest of the files will be renamed as if the interactive mode was disabled."
        show_warning=false
      }
      if [[ "${f}" == "${newname}" ]]; then
        info "File [$f] is already normalized, skipping."
        continue
      fi
      info "About to rename [$f] into [${newname}]..."
      run.ui.ask-user-value answer "Rename the file? ${bldylw}(yes,y/no,n/all,a/quit,q): "
      case ${answer} in
        q|quit|Q|Quit)
          info "Aborting the rename as requested."
          exit 1
          ;;
        y|Y|yes|Yes)
          run "${command}"
          ;;
        n|N|no|No)
          info "Skipping file ${f}..."
          continue
          ;;
        a|all|A|All)
          info "Turning off interactive mode..."
          interactive=false
          run "${command}"
          ;;
        *)
          error "Answer ${answer} is invalid. Try again."
          exit 1
          ;;
      esac
    else 
      if ${verbose}; then
        run "${command}" 
      else
        eval "${command}"
      fi
      sleep 0.05
    fi
  done
  return 0
}
