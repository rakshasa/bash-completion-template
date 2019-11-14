Bash Completion Template
========================

Introduction
------------

This project provides a template for creating bash completion scripts
that support nested command namespaces.


Getting Started
---------------

Copy the `template.bash` file and replace `{{bc_namespace}}`, `{{bc_executable}}` and
`{{bc_command}}`. Add your changes above the `# completion function`
line so that the scripts for importing from and updating the template
works correctly.

```bash
touch ~/rtorrent-docker/misc/rtorrent-docker.bash
/update rtorrent_docker rt_do "rt-do rt-do.exe" ~/rtorrent-docker/misc/rtorrent-docker.bash 
```

Update your file with the latest changes to `template.bash`.

```bash
./import ~/rtorrent-docker/misc/rtorrent-docker.bash
```

Update `template.bash` with changes made to your file below the `#
completion function` line.


Template Placeholders
---------------------

```bash
{{bc_namespace}} # all bash functions are prepended with "_{{bc_namespace}}_"
{{bc_executable}} # the filename of the executable binary
{{bc_command}} # the bash-friendly name appended to the namespace
```

Helper Functions
----------------

```bash
# arg_funcs+=(--foo##skip)
# arg_funcs+=(--foo#_bazspace__skip)
# arg_funcs+=(--foo##compgen#-o#default)
```

Adds a handler for the flag `--foo` so it calls `_bazspace__skip`, with `##` adding the namespace prefix and subsequent `#` adding arguments.
