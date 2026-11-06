# Instructions

## Opening the Nextflow environment

To avoid installation and configuration issues we are going to deploy an environment for you containing Nextflow and its requirements.

If you want to open directly a GitHub codespace for this specific repository click here: [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/biosustain/dsp_nextflow_training)

Don't change the configuration and accept the default option. It says pay but you're not paying: every personal GitHub account includes free Codespaces usage every month (120 core hours on the Free plan, that is 60 hours on the default 2-core machine), which is much more than what we need today.

If you want to do it manually go to [course website](https://github.com/biosustain/dsp_nextflow_training)

Click on button **Code** and click on the Codespaces tab. There click on **Create codespace**. Now your Nextflow environment will be built following the instructions in devcontainer.json file (i.e. installing Ubuntu, Docker, and VSCode with needed extensions) with additional customization added in the Dockerfile (i.e, installing java, Nextflow and nf-core tools).

To learn more about Github codespaces go [here](https://github.com/features/codespaces)

>Please remember to delete your Codespace by the end of the class so that you do not consume your free Github codespace credits! If you do not delete your codespace, it will be deleted automatically after it has been stopped and inactive for 30 days (by default).

## Initial checks
Now, Nextflow should be ready to run in your GitHub Codespace environment! Let's check that you have a fully functional environment with Nextflow, java, nf-core tools and Docker properly installed.

Verify java installation:
```bash
java -version
```

Verify Nextflow installation:
```bash
nextflow -v
```

Nextflow current version, system and runtime:
```bash
nextflow info
```

Verify nf-core tools installation:
```bash
nf-core --version
```

Verify Docker installation:
```bash
docker --version
```

If everything went well you have a fully functional Nextflow environment for today! Remember that we are going to use VS code as our editor to write code and handle our files.

## Local installation

If you want to use Nextflow on your own computer after the course, follow these steps (based on the [Nextflow installation guide](https://www.nextflow.io/docs/latest/install.html)).

Nextflow runs on any POSIX-compatible system (Linux, macOS, etc.), and on Windows through WSL (see below).

### Requirements

Requirements are:
- Bash 3.2 or later, and curl
- Java 17 or later (up to 26). The codespace uses Java 21
- Git
- Docker (not needed for the first script that you will write but needed in general for Nextflow)

Good to have:
If you are using it in Azure it is good to have your Azure Batch, Azure Storage, Virtual machine and network where all these features are set up together with your managed identities (credentials). Ask the RDM team for that.

### Java

Check which version of Java you have:
```bash
java -version
```

If you do not have Java 17 or later, the Nextflow documentation recommends to install it with [SDKMAN!](https://sdkman.io/) and to use the latest Long-Term-Support (LTS) version of Temurin:
```bash
curl -s https://get.sdkman.io | bash
```

Open a new terminal, then install Java:
```bash
sdk install java
```

### Download and install Nextflow

Execute the following in your terminal to download Nextflow:
```bash
curl -s https://get.nextflow.io | bash
```

Next, we make sure that the downloaded binary is executable:
```bash
chmod +x nextflow
```

Finally, move the nextflow executable to a directory in your `$PATH`. The Nextflow documentation recommends a directory in your home folder, such as `$HOME/.local/bin/`, rather than a system directory like `/usr/local/bin`: Nextflow updates its own executable, and the update can fail in a directory with restricted permissions.
```bash
mkdir -p $HOME/.local/bin/
mv nextflow $HOME/.local/bin/
```

If `$HOME/.local/bin/` is not yet in your `$PATH`, add this line to your shell configuration file (e.g. `~/.bashrc` or `~/.zshrc`) and open a new terminal:
```bash
export PATH="$PATH:$HOME/.local/bin"
```

Confirm that Nextflow is installed correctly:
```bash
nextflow info
```

> Nextflow can also be installed with Conda (`conda create --name nf-env bioconda::nextflow`), but the Nextflow documentation warns that it may give outdated versions and Java compatibility issues, so the self-installing package above is recommended.

### Updating Nextflow and choosing a version

A stable version of Nextflow is released every April and October (e.g. 26.04 and 26.10). To update to the latest stable version:
```bash
nextflow self-update
```

To run a specific version of Nextflow, set the `NXF_VER` environment variable. For example, to use the same version as in the codespace:
```bash
NXF_VER=26.10.4 nextflow info
```

> Notice that in our codespace the Dockerfile in `.devcontainer` downloads a fixed Nextflow version (26.10.4) so that everybody runs the tutorial with the same version.

### Docker

To install Docker follow this [link](https://docs.docker.com/get-started/get-docker/) and download the version that matches your OS.

### Nextflow in Windows

Nextflow does not run natively on Windows: it is developed for POSIX-compatible systems (Linux and macOS). On Windows, install the Windows Subsystem for Linux (WSL) and install Nextflow inside it, following the steps above. WSL allows you to run a Linux environment on Windows providing access to Unix-like tools and environments, enabling compatibility with Docker for containerized workflows, and resolving many possible compatibility issues related to the file system and paths.
