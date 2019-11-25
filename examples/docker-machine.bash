# bash completion for docker-machine

# argument helper functions

_docker_machine__filter() {
  _docker_machine__word_skip

  if (( ${iword} == ${cword} )); then
    COMPREPLY=($(compgen -W "driver label name state swarm" -S= -- "${cur}"))
    _docker_machine__nospace
    return 1
  else
    iword=$(( ${iword} + 2 ))
  fi
}

_docker_machine__filter_nospace() {
  _docker_machine__word_skip

  if (( ${iword} == ${cword} )); then
    COMPREPLY=($(compgen -W "driver label name state swarm" -S= -- "${cur}"))
    _docker_machine__nospace
    return 1
  # else
  #   iword=$(( ${iword} + 2 ))
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
    # Need a way to indicate no-space for flags.
    flags=(--filter#--filter= --format --help --quiet --timeout)
    arg_funcs=(
      --filter=##filter_nospace
      --filter##filter
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
    # Word is the current word being completed.
    # Rword is the regexp pattern used when looking up arg_func.
    local word=${words[iword]} rword=${words[iword]}
    local completion_func=_docker_machine__${command_current}

    # Matching commands move the interpreter down a command layer while flags are handled in the same layer.
    commands=() flags=() arg_funcs=()

    if ! declare -F "${completion_func}" > /dev/null || ! ${completion_func}; then
      # No conversion of '#' is done, the completion_func is responsible for cleaning up commands/flags.
      return 0
    fi

    # Do not allow '#' in commands or flags.
    if [[ "${word}" =~ '#' ]]; then
      return 0
    fi

    if (( ${iword} == ${cword} )); then
      # If non-empty word and no root commands are matched, include all aliased commands.
      if [[ -z "${word}" ]] || [[ " ${commands[*]} " =~ \ ${word}([^# ]*)(#| ) ]]; then
        commands=(${commands[@]//#[^ ]*/})
      else
        commands=(${commands[@]//#/ })
      fi

      # If non-empty word and no root flags are matched, include all aliased flags.
      if [[ -z "${word}" ]] || [[ " ${flags[*]} " =~ \ ${word}([^# ]*)(#| ) ]]; then
        flags=(${flags[@]//#[^ ]*/})
      else
        flags=(${flags[@]//#/ })
      fi

      break
    fi

    if [[ " ${commands[*]} " =~ " ${word} " ]]; then
      # TODO: Allow aliases for commands.
      command_current=${command_current}_${word//-/_}
      command_pos=${iword}
    elif [[ " ${flags[*]} " =~ \ ${word}(#| ) ]]; then
      : # Always make your : mean :, and your ! mean !.
    elif [[ " ${flags[*]} " =~ \ ([^ ]*)#${word}(#| ) ]] ; then
      # Match current word or root flag.
      rword="${rword}|${BASH_REMATCH[1]%%#*}"
    else
      return 0
    fi

    local arg_func=
    local iarg=

    for (( iarg=0; iarg < ${#arg_funcs[@]}; ++iarg )); do
      if [[ "${arg_funcs[iarg]}" =~ ^(${rword})##([^$]*)$ ]]; then
        arg_func="_docker_machine__${BASH_REMATCH[2]//#/ }"
      elif [[ "${arg_funcs[iarg]}" =~ ^(${rword})#([^$]*)$ ]]; then
        arg_func="${BASH_REMATCH[2]//#/ }"
      fi
    done

    if [[ -n "${arg_func}" ]] && ! ${arg_func}; then
      return 0
    fi
  done

  local compreply=("${commands[*]}" "${flags[*]}")
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
