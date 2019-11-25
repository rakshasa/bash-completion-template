# bash completion for {{bc_namespace}}
#
# {{bc_namespace}} # all bash functions are prepended with "_{{bc_namespace}}_"
# {{bc_command}} # the bash-friendly name appended to the namespace
# {{bc_executable}} # the filename of the executable binary(s)

# Only get a list of valid completions when we've reached the last
# word. By incrementing 'iword' we have moved from the command/flag to
# the next word, the argument to that command/flag.
#
# _{{bc_namespace}}__docker_images() {
#   commands=() flags=()
#   iword=$(( ${iword} + 1 ))
#
#   if (( ${iword} == ${cword} )); then
#     commands=($(docker images))
#   fi
# }
#
# If this is the last word, generate the list of valid arguments and
# append them without space after an '=' sign. By setting COMPREPLY
# here explicitly and returning '1' we exit the main loop without
# using the default completion handler.
#
# By using '"${words[0]}"' we call {{bc_command}}.
#
# _{{bc_namespace}}__docker_args() {
#   commands=() flags=()
#   iword=$(( ${iword} + 1 ))
#
#   if (( ${iword} == ${cword} )); then
#     COMPREPLY=($(compgen -W "$("${words[0]}" docker args)" -S= -- "${cur}"))
#     _{{bc_namespace}}__nospace
#     return 1 
#   fi
# }
#
# _{{bc_namespace}}__{{bc_command}}_build_all() {
#   # by not checking for '-*' one does not need to type '-' to
#   # complete these flags
#   flags=(--build-arg --no-cache --base-image --help)
#   flag_funcs=(
#     --base-image####docker_images#--quiet
#     --build-arg##docker_args
#   )
# }
#
# _{{bc_namespace}}__{{bc_command}}_build() {
#   if [[ "${word}" == -* ]]; then
#     flags=(--help)
#   else
#     commands=(all)
#   fi
# }
#
# _{{bc_namespace}}__{{bc_command}}() {
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
# COMMAND={{bc_command}}
# EXECUTABLE="{{bc_executable}}"

_{{bc_namespace}}_{{bc_command}}() {
  COMPREPLY=()

  local cur prev words cword
  _get_comp_words_by_ref -n : cur prev words cword
  local commands flags arg_funcs
  local command_current={{bc_command}} command_pos=0 iword=0 cskip=0

  for (( iword=1; iword <= ${cword}; ++iword)); do
    # Word is the current word being completed.
    # Rword is the regexp pattern used when looking up arg_func.
    local word=${words[iword]} rword=${words[iword]}
    local completion_func=_{{bc_namespace}}__${command_current}

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
        arg_func="_{{bc_namespace}}__${BASH_REMATCH[2]//#/ }"
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

_{{bc_namespace}}__time() {
  _{{bc_namespace}}_{{bc_command}} "${@}"
  #time _{{bc_namespace}}_{{bc_command}} "${@}"
}

complete -F _{{bc_namespace}}__time {{bc_executable}}

# helper functions
#
# arg_funcs+=(--foo##skip)
# arg_funcs+=(--bar#_{{bc_namespace}}__skip)
# arg_funcs+=(--baz##compgen#-o#default)

_{{bc_namespace}}__compgen() {
  COMPREPLY=($(compgen $(printf "-o %s" "${@}")))
  return 1
}

_{{bc_namespace}}__compopt() {
  # compopt is not available in ancient bash versions (OSX)
  # so only call it if it's available
  type compopt &>/dev/null && compopt $(printf "-o %s" "${@}")
}

_{{bc_namespace}}__nospace() {
  # compopt is not available in ancient bash versions (OSX)
  # so only call it if it's available
  type compopt &>/dev/null && compopt -o nospace
}

_{{bc_namespace}}__word_skip() {
  commands=() flags=()
  iword=$(( ${iword} + 1 ))
}
