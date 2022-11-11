#!/usr/bin/env bash

# Usage:
#   aws.rds.hostname 'database-name'
# Eg:
#   aws.rds.hostname
aws.rds.hostname() {
  local name=${1}
  [[ -z $(which jq) ]] && out=$(brew.install.package jq 2>/dev/null 1>/dev/null)
  [[ -z $(which aws) ]] && out=$(brew.install.package awscli 2>/dev/null 1>/dev/null)

  [[ -n ${name} ]] && aws rds describe-db-instances | jq '.[][].Endpoint.Address' | sedx 's/"//g' | ${GrepCommand} "^${name}\."
  [[ -z ${name} ]] && aws rds describe-db-instances | jq '.[][].Endpoint.Address' | sedx 's/"//g'
}

# This this global to upload all assets there.
export LibAws__DefaultUploadBucket=${LibAws__DefaultUploadBucket:-""}
export LibAws__DefaultUploadFolder=${LibAws__DefaultUploadFolder:-""}
export LibAws__DefaultRegion=${LibAws__DefaultRegion:-"us-west-2"}

aws.s3.upload() {
  local pathname="$1"
  shift
  local skip_file_modification="$1"
  [[ -n ${skip_file_modification} ]] && skip_file_modification=true
  [[ -z ${skip_file_modification} ]] && skip_file_modification=false

  if [[ -z "${LibAws__DefaultUploadBucket}" || -z "${LibAws__DefaultUploadFolder}" ]]; then
    error "Required AWS S3 configuration is not defined." \
      "Please set variables: ${bldylw}LibAws__DefaultUploadFolder" \
      "and ${bldylw}LibAws__DefaultUploadBucket" \
      "before using this function."
    return 1
  fi

  if [[ ! -f "${pathname}" ]]; then
    error "Local file was not found: ${bldylw}${pathname}"
    return 1
  fi

  local file=$(basename "${pathname}")
  local remote_file="${file}"
  local year=$(file.last-modified-year "${pathname}")
  local date=$(file.last-modified-date "${pathname}")

  [[ -z ${year} ]] && year=$(date +'%Y')
  [[ -z ${date} ]] && date=$(today)

  ${skip_file_modification} || {
    # remove the date from file, in case it's at the end or something
    [[ "${remote_file}" =~ "${date}" ]] && remote_file=$(echo "${remote_file}" | sedx "s/[_\.-]?${date}[_\.-]//g")

    # prepend the date to the beginning of the file unless already in the file
    [[ "${remote_file}" =~ "${date}" ]] || remote_file="${date}.${remote_file}"

  }
  # clean up spaces
  remote_file=$(echo "${remote_file}" | sed -E 's/ /-/g;s/--+/-/g' | tr '[A-Z]' '[a-z]')

  local remote="s3://${LibAws__DefaultUploadBucket}/${LibAws__DefaultUploadFolder}/${year}/${remote_file}"

  run "aws s3 cp \"${pathname}\" \"${remote}\""

  if [[ ${LibRun__LastExitCode} -eq 0 ]]; then
    local remoteUrl="https://s3-${LibAws__DefaultRegion}.amazonaws.com/${LibAws__DefaultUploadBucket}/${LibAws__DefaultUploadFolder}/${year}/${remote_file}"
    [[ -n "${LibAws__ObjectUrlFile}" ]] && echo "${remoteUrl}" >"${LibAws__ObjectUrlFile}"
    echo
    info "NOTE: You should now be able to access your resource at the following URL:"
    hr
    info "${bldylw}${remoteUrl}"
    hr
  else
    error "AWS S3 upload failed with code ${LibRun__LastExitCode}"
  fi
  return "${LibRun__LastExitCode}"
}

__utf_table() {
  echo -n "$@" | sed -e "s/-/—/g;s/+/•/g;s/—|—/─┬─/g;s/—/─/g;s/[|•]/│/g"
}

aws.ec2() {
  local cmd="$1"
  local command="$cmd"

  case $command in
  list | show | ls)
    __utf_table "$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{name: Name, instance_id: InstanceId, ip_address: PrivateIpAddress, state: State.Name}' --output table 2>/dev/null)"
    return $?
    ;;
  *)
    error "Invalid Command: ${cmd}"
    return 1
    ;;
  esac
}


