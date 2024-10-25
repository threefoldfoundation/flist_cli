<h1> Flist CLI in Vlang </h1>

<h2>Table of Contents</h2>

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Makefile Installation](#makefile-installation)
  - [Building and Installing with Makefile](#building-and-installing-with-makefile)
  - [Rebuilding and Uninstalling with Makefile](#rebuilding-and-uninstalling-with-makefile)
- [Manual Installation](#manual-installation)
- [Available Commands](#available-commands)
- [Usage](#usage)
- [OS-Specific Instructions](#os-specific-instructions)
  - [Linux](#linux)
  - [macOS](#macos)
  - [Windows](#windows)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

---

## Introduction

Flist CLI is a tool that turns Dockerfiles and Docker images directly into Flist on the TF Flist Hub, passing through Docker Hub.

## Prerequisites

- [V programming language](https://vlang.io/) (latest version) installed on your system
- [Docker Engine](https://docs.docker.com/engine/install/) installed and running (Linux)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running (MacOS+Windows)
- [Docker Hub](https://hub.docker.com/) account
- [TF Hub](https://hub.grid.tf/) account and token
- Makefile (optional)

Read more on the TF Hub and Flist on the ThreeFold Manual [here](https://manual.grid.tf/documentation/developers/flist/flist.html).

## Makefile Installation

### Building and Installing with Makefile

- To clone this repository, build the project, and install the CLI:
  - MacOS and Linux
    ```
    git clone https://github.com/threefoldfoundation/flist_cli
    cd flist_cli
    make build
    ```
  - Windows
    ```
    git clone https://github.com/threefoldfoundation/flist_cli
    cd flist_cli
    make build-win
    ```

This will build the executable and install it to the appropriate system location.

### Rebuilding and Uninstalling with Makefile

You can use the following Makefile commands:

- To rebuild and reinstall:
  - MacOS and Linux
    ```
    make rebuild
    ```
  - Windows
    ```
    make rebuild-win
    ```

- To uninstall and remove the binary:
  - MacOS and Linux
    ```
    make delete
    ```
  - Windows
    ```
    make delete-win
    ```

## Manual Installation

You can install the Flist with the following commands. You do not need Makefile to use the Flist CLI.

- Linux and MacOS
  - Build
    ```
    v fmt -w flist.v
    v -o flist .
    sudo ./flist install
    ``` 
  - Rebuild
    ```
    sudo flist uninstall
    v fmt -w flist.v
    v -o flist .
    sudo ./flist install
    ``` 
  - Delete
    ```
    sudo flist uninstall
    ``` 
- Windows
  - Build
    ```
    v fmt -w flist.v
    v -o flist .
    ./flist.exe install
    ``` 
  - Rebuild
    ```
    ./flist.exe uninstall
    v fmt -w flist.v
    v -o flist .
    ./flist.exe install
    ``` 
  - Delete
    ```
  	./flist.exe uninstall
    ``` 

## Available Commands

After installation, you can use the `flist` command followed by various subcommands:

```
flist <command> [arguments]
```

Run `flist` or `flist help` to see all available commands for your specific OS.

- `install`   - Install the Flist CLI
- `uninstall` - Uninstall the Flist CLI
- `login`     - Log in to Docker Hub and save the Flist Hub token
- `logout`    - Log out of Docker Hub and remove the Flist Hub token
- `push`      - Build and push a Docker image to Docker Hub, then convert and push it as an Flist to Flist Hub
- `delete`    - Delete an Flist from Flist Hub
- `rename`    - Rename an Flist in Flist Hub
- `ls`        - List all Flists of the current user
- `ls url`    - List all Flists of the current user with full URLs
- `help`      - Display this help message

## Usage

A Linux user would use the following commands:

```
sudo ./flist install
sudo flist uninstall
flist login
flist logout
flist push <image>:<tag>
flist delete <flist_name>
flist rename <flist_name> <new_flist_name>
flist ls
flist ls url
flist help
```

## OS-Specific Instructions

### Linux

1. Ensure Docker Engine is installed and running.
2. The `flist` executable will be installed to:
   ```
   /usr/local/bin/flist
   ```

### macOS

1. Ensure Docker Desktop is installed and running.
2. The `flist` executable will be installed to:
   ```
   /usr/local/bin/flist
   ```

### Windows

1. Ensure Docker Desktop is installed and running.
2. Run the program and installer in an admin PowerShell.
3. The `flist.exe` executable will be installed to:
   ```
   C:\\Program Files\\flist\\flist.exe
   ```

## Troubleshooting

- If you encounter permission issues, ensure you're running the command with appropriate privileges (e.g., as administrator on Windows or with `sudo` on Unix-like systems).
- If you face issues with Docker commands, try logging out and logging back in to refresh your Docker credentials.
- If you encounter compilation errors, ensure you have the latest version of V installed. To update v, run `v up`.

## Development

To modify the Flist CLI:

1. Make your changes to the `flist.v` file.
2. Rebuild the project using using the appropriate Make command.
3. Test your changes thoroughly across different operating systems if possible.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Apache 2.0 License](LICENSE)