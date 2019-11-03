Bash Completion Template
========================

Introduction
------------

This project provides a template for creating bash completion scripts
that support nested command namespaces.


Getting Started
---------------

Copy the `template.bash` file and replace `{{bc_namespace}}` and
`{{bc_executable}}`. Add your changes above the `# completion function`
line so as to make importing from and updating the template work.

```bash
/update rtorrent_docker do ~/rtorrent-docker/misc/rtorrent-docker.bash
```

Update your file with the latest changes to `template.bash`.

```bash
./import ~/rtorrent-docker/misc/rtorrent-docker.bash
```

Update `template.bash` with changes made to your file below the `#
completion function` line.
