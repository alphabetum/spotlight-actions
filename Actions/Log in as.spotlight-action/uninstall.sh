#!/usr/bin/env bash

_uninstall_action_log_in_as() {
  local _users_and_realnames
  _users_and_realnames=($(dscl . list /Users RealName | grep -v '^_'))

  for __user in ${_users_and_realnames[@]}
  do
    local _username
    _username="$(echo "${__user}" | awk '{print $1}')"

    local _realname
    _realname="$(echo "${__user}" | awk '{$1=""; print substr($0,2)}')"

    # Only print users with valid home directories, which is used here as an
    # indication that the account is a valid login account. So far I've been
    # unable to find a better way to list only full login user accounts.
    local _home_directory
    _home_directory="$(
      dscl . -read "/Users/${_username}" NFSHomeDirectory | \
        awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'
    )"

    # Skip system users
    if [[ "${_username}" == "root" ]]         ||
       [[ "${_username}" == "daemon" ]]       ||
       [[ "${_home_directory}" =~ ^/var.* ]]  ||
       [[ "${_home_directory}" =~ ^/dev.* ]]  ||
       [[ "${_home_directory}" =~ ^/opt.* ]]
    then
      continue
    fi

    local _app_name="Log in as ${_realname} (${_username}).app"

    if [[ ! -d "${_TARGET_DIRECTORY}/${_app_name}" ]]
    then
      printf "'%s' not installed.\\n" "${_app_name}" 1>&2
    fi

    _remove "${_TARGET_DIRECTORY}/${_app_name}" \
      && printf "'%s' uninstalled.\\n" "${_app_name}"
  done
} && _uninstall_action_log_in_as
