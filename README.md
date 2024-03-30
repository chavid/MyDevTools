
# News

## 2023-01-20

- alias `dbash` is renamed `drun`.
- `drun` (alias to `run.sh`), `dbuild` (alias to `build.sh`) and `drecipe` (alias to `recipe.sh`) have been given few options, including `-h` to print a short help.
- new recipe `Python3`.


# General use

Starting from a bash shell, and staying into any directory, one should source `<DevScripts>/env.bash`. This will make available the following commands:
- `drecipe`: alias to the `recipe.sh` script, which recursively search for a `Dockerfile` ; a subdirectory can be provided as argument, where to search for the recipe ; if not, the script scan the current directory, then the `<DevScripts>` one.
- `dbuild`: alias to the `build.sh` script, building the docker image and tagging it with the name within `Dockertag`.
- `drun`: alias to the `run.sh` script, will start a new interactive container, from the docker image whose name is taken from `Dockertag`, mount the current working directory as `/work`, and start a bash shell.

Those other commands  are available after in the orginal bash shell, once `env.bash` has been source:
- `count`: count the code lines in the current directory and subdirectories.
- `oval`: automatically run regression tests and/or various set of commands.

If the docker recipe include a copy of `<DevScripts>/bin` as `/mydevtools` in the image, and define `bash --rcfile /mydevtools/bashrc` as the default image command (`CMD`), then the utilities above will also be available in the corresponding containers.


# Files in `bin` subdirectory

Docker related:
* `recipe.sh`: script used to find a recipe.
* `build.sh`: script used to build the image.
* `run.sh`: script used to run the image.

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

# Recipe tips

## Mydevtools

If one want to get the devtools duplicated in the image,
and the devtools setup and PS1 prompt, one should add to the end of the recipe:

```
# Local copy of my tools
COPY mydevtools /mydevtools

# Start a shell by default
CMD bash --rcfile /mydevtools/bashrc
```


## Pip may be a problem

When things are installed as root with `pip` in a recipe, if you run the container as
non-root, you may encounter access right problems, especially when running notebooks. 


# Ressources

- https://www.redhat.com/sysadmin/arguments-options-bash-scripts
- https://fr.wikibooks.org/wiki/Programmation_Bash/Tests
- https://www.golinuxcloud.com/bash-getopts/
