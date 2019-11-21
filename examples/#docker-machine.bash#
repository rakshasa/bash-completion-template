# bash completion for docker-machine

# argument helper functions

_docker_machine__filter() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))

  if (( ${iword} == ${cword} )); then
    COMPREPLY=($(compgen -W "$("${words[0]}" docker args)" -S= -- "${cur}"))
    _rtorrent_docker__nospace
    return 1
  fi
}

# completion docker-machine layer

_docker_machine__cmd() {
  if [[ "${word}" == -* ]]; then
    flags=(--help --version)
  else
    commands=(active ls)
  fi
}

_docker_machine__cmd_ls() {
  if [[ "${word}" == -* ]]; then
    flags=(--filter --format --help --quiet --timeout)
    flag_funcs=(
      filter##filter
    )
  fi
}

# completion function
#
# https://github.com/rakshasa/bash-completion-template
#
# NAMESPACE=docker_machine
# COMMAND=cmd
# EXECUTABLE="docker-machine docker-machine.exe"

_docker_machine_cmd() {
  COMPREPLY=()

  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword
  local commands flags arg_funcs
  local command_current=cmd command_pos=0 iword=0 cskip=0

  for (( iword=1; iword <= ${cword}; ++iword)); do
    local word=${words[iword]}
    local completion_func=_docker_machine__${command_current}

    commands=() flags=() arg_funcs=()

    if ! declare -F "${completion_func}" > /dev/null || ! ${completion_func}; then
      return 0
    fi

    if (( ${iword} == ${cword} )); then
      break
    elif [[ " ${commands[*]} " =~ " ${word} " ]]; then
      command_current=${command_current}_${word//-/_}
      command_pos=${iword}
    elif ! [[ " ${flags[*]} " =~ " ${word} " ]]; then
      return 0
    fi

    local arg_func=
    local iarg=

    for (( iarg=0; iarg < ${#arg_funcs[@]}; ++iarg )); do
      if [[ "${arg_funcs[iarg]}" =~ ^${word}##([^$]*)$ ]]; then
        arg_func="_docker_machine__${BASH_REMATCH[1]//#/ }"
      elif [[ "${arg_funcs[iarg]}" =~ ^${word}#([^$]*)$ ]]; then
        arg_func="${BASH_REMATCH[1]//#/ }"
      fi
    done

    if [[ -n "${arg_func}" ]] && ! ${arg_func}; then
      return 0
    fi
  done

  local compreply=("${flags[*]}" "${commands[*]}")
  COMPREPLY=($(compgen -W "${compreply[*]}" -- "${cur}"))

  return 0
}

_docker_machine__time() {
  _docker_machine_cmd "${@}"
  #time _docker_machine_cmd "${@}"
}

complete -F _docker_machine__time docker-machine docker-machine.exe

# helper functions
#
# arg_funcs+=(--foo##skip)
# arg_funcs+=(--bar#_docker_machine__skip)
# arg_funcs+=(--baz##compgen#-o#default)

_docker_machine__compgen() {
  COMPREPLY=($(compgen $(printf "-o %s" "${@}")))
  return 1
}

_docker_machine__compopt() {
  # compopt is not available in ancient bash versions (OSX)
  # so only call it if it's available
  type compopt &>/dev/null && compopt $(printf "-o %s" "${@}")
}

_docker_machine__nospace() {
  # compopt is not available in ancient bash versions (OSX)
  # so only call it if it's available
  type compopt &>/dev/null && compopt -o nospace
}

_docker_machine__word_skip() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))
}
