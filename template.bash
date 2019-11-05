# bash completion for {{bc_namespace}}

# _{{bc_namespace}}__{{bc_executable}}_build_all() {
#   # by not checking for '-*' one does not need to type '-' to
#   # complete these flags
#   flags=(--build-arg --no-cache --help)
#   flag_funcs[--build-arg]=_{{bc_namespace}}__{{bc_executable}}_arg_skip
# }

# _{{bc_namespace}}__{{bc_executable}}_build() {
#   if [[ "${word}" == -* ]]; then
#     flags=(--help)
#   else
#     commands=(all)
#   fi
# }

# _{{bc_namespace}}__{{bc_executable}}() {
#   if [[ "${word}" == -* ]]; then
#     flags=(--help)
#   else
#     commands=(build clone)
#   fi
# }

# completion function
#
# https://github.com/rakshasa/bash-completion-template
#
# NAMESPACE={{bc_namespace}}
# EXECUTABLE={{bc_executable}}

_{{bc_namespace}}_{{bc_executable}}() {
  COMPREPLY=()

  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword
  local commands flags flag_funcs
  local command_current={{bc_executable}} command_pos=0 iword=0 cskip=0

  for (( iword=1; iword <= ${cword}; ++iword)); do
    local word=${words[iword]}
    local completion_func=_{{bc_namespace}}__${command_current}

    commands=() flags=() flag_funcs=()

    if ! declare -F "${completion_func}" > /dev/null || ! ${completion_func}; then
      return 0
    fi

    if (( ${iword} == ${cword} )); then
      break
    elif [[ " ${commands[*]} " =~ " ${word} " ]]; then
      command_current=${command_current//-/_}_${word}
      command_pos=${iword}
    elif [[ " ${flags[*]} " =~ " ${word} " ]]; then
      local flag_func
      local iflag

      for (( iflag=0; iflag < ${#flag_funcs[@]}; ++iflag )); do
        if [[ "${flag_funcs[iflag]}" =~ ^${word}//([^$]*)$ ]]; then
          flag_func="${BASH_REMATCH[1]}"
        fi
      done

      if [[ -n "${flag_func}" ]] && ! ${flag_func}; then
        return 0
      fi
    else
      return 0
    fi
  done

  local compreply=("${flags[*]}" "${commands[*]}")
  COMPREPLY=($(compgen -W "${compreply[*]}" -- "${cur}"))

  return 0
}

_{{bc_namespace}}_{{bc_executable}}_time() {
  _{{bc_namespace}}_{{bc_executable}} "${@}"
  #time _{{bc_namespace}}_{{bc_executable}} "${@}"
}

complete -F _{{bc_namespace}}_{{bc_executable}}_time {{bc_executable}}

# helper functions
#
# flag_funcs+=(--arg//_{{bc_namespace}}_{{bc_executable}}_skip)

_{{bc_namespace}}_{{bc_executable}}_default_bashdefault() {
  COMPREPLY=($(compgen -o default -o bashdefault))
  return 1
}

_{{bc_namespace}}_{{bc_executable}}_skip() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))
}

_{{bc_namespace}}_{{bc_executable}}_nospace() {
  # compopt is not available in ancient bash versions (OSX)
  # so only call it if it's available
  type compopt &>/dev/null && compopt -o nospace
}
