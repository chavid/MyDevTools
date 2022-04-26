
# General use

Starting from a bash shell, and staying into any directory, one should source `<DevScripts>/env.sh [<SubDir>]`. If `<SubDir>` is given, the script will search locally if `./<SubDir>` contains a Docker recipe and tag. If not found locally, it will search the same in `<DevScripts>/<SubDir>`. If `<SubDir>` is not given, the script will search a recipe recursively from the current directory.

This will make available the following commands:
- `dbuild`: alias to the `build.sh` script, building the docker image and tagging it with the name within `Dockertag`.
- `dbash`: alias to the `run.sh` script, will start a new interactive container, from the docker image whose name is taken from `Dockertag`, mount the current working directory as `/work`, and start a bash shell.

Those other commands  are available after in the orginal bash shell, once `env.sh` has been source:
- `count`: count the code lines in the current directory and subdirectories.
- `oval`: automatically run regression tests and/or various set of commands.

If the docker recipe include a copy of `<DevScripts>/bin` as `/mydevtools` in the image, and define `bash --rcfile /mydevtools/bashrc` as the default image command (`CMD`), then the utilities above will also be available in the corresponding containers.


# Files in `bin` subdirectory

Docker related:
* `build.sh` : script used to build the image.
* `run.sh` : script used to run the image.

Other utilities
- `count.sh`: count the code lines in the current directory and subdirectories.
- `oval.py`: automatically run regression tests and/or various set of commands.


# Files in other subdirectories

* `Dockerfile` : docker recipe.
* `Dockertag` : name to be given to the docker image.


# Quick and dirty recipes for `oval`

Typing `oval` or `oval l` will display the list of targets, as described in in ovalfile.py.
Each target is the association between a name and a shell command.

Typing `oval r <name>` will execute the shell command associated with the given name
One can execute several ones sequentially: `oval r <name1> <name2>...`

Typing `oval fo <name>` show the filtered part of `<name>.out`.
Typing `oval v  <name>` copy the log file `<name>.out` into the ref file `<name>.ref`.
Typing `oval d  <name>` compare the log file `<name>.out` with the ref file `<name>.ref`.
Typing `oval fo <name>` show the filtered part of `<name>.out`.
Typing `oval fr <name>` show the filtered part of `<name>.ref`.
Typing `oval c  <name>` crypt `<name>.ref` into `<name>.md5`.

One can use wildcards: `oval r <pattern1> <pattern2>...`
The only wildcard character is `%`.
One can check how a given pattern expands : `oval l <pattern>`.

On top of the targets, the configuration `ovalfile.py` can include a list of filters.
When one run several targets, only the ouput lines which match one of the filters
are displayed.


