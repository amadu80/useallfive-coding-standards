How to install the pre-commit hook.
====================================

Copy the pre-commit hook into the .git/hooks folder of your local git
repository. You can do this by hand or by calling:
```bash
./install_hooks.sh /path/to/repository
```

The script will ask if any existing files are to be overwritten.
Note that the existing pre-commit hook has to be overwritten.
You can rename it and add it to the list of executed hooks in the
pre-commit file included with these scripts to have it executed as
before.

Some of the pre-commit hooks have settings that need to be specified.
They should be self-explanatory and are located at the top of the
respective file. If a hook fails because of invalid settings it will
report it and abort the commmit.

