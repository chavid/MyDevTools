
# General use

Starting from a bash shell, one should source `bin/env.sh <SUBDIR>`, with the selected subdirectory as argument (for example `DevCpp20`). This will make available the following commands:
- `dbuild`: alias to the `build.sh` script, building the docker image and tagging it with the name within `image.txt`.
- `drun [arguments]`: alias to the `run.sh` script, will start a new interactive container, from the docker image whose name is taken from `image.txt`, and mounting the current working directory as `/work`.

Also few utilities:
- `count`: count the code lines in the current directory and subdirectories.

# Files in `bin` subdirectory

Docker related:
* `build.sh` : script used to build the image.
* `run.sh` : script used to build the image.

Other utilities
* `compte.sh` : script used to build the image.

# Files in other subdirectories

* `Dockerfile` : docker recipe.
* `image.txt` : name to be given to the docker image.



