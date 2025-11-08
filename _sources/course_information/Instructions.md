# Instructions

## Opening the Nextflow environment

To avoid installation and configuration issues we are going to deploy an environment for you containing Nextflow and its requirements.

If you want to open directly a GitHub codespace for this specific repository click here: [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/biosustain/dsp_nextflow_training)

Don't change the configuration and accept the default option. It says pay but you're not paying...

If you want to do it manually go to [course website](https://github.com/biosustain/dsp_nextflow_training)

Click on button **Code** and click on the Codespaces tab. There click on **Create codespace**. Now your Nextflow environment will be built following the instructions in devcontainer.json file (i.e. installing Ubuntu, Docker, and VSCode with needed extensions) with additional customization added in the Dockerfile (i.e, installing java and Nextflow).

To learn more about Github codespaces go [here](https://github.com/features/codespaces)

>Please remember to delete your Codespace by the end of the class so that you do not consume your free Github codespace credits! If you do not delete your codespaces they will be deleted automatically days after your created.

## Initial checks
Now, Nextflow should be ready to run in your GitHub Codespace environment! Let's check that you have a fully functional environment with Nextflow, java and Docker properly installed

```{code-block} bash
:caption: Verify java installation:

java -version
```

```{code-block} bash
:caption: Verify Nextflow installation:

nextflow -v
```

```{code-block} bash
:caption: Nextflow current version, system and runtime:

nextflow info
```

```{code-block} bash
:caption: Verify Docker installation:

docker --version
```

If everything went well you have a fully functional Nextflow environment for today! Rememeber that we are going to use VS code as our editor to write code and handle our files.

## Local installation

Some requirements will be different depending on your local machine operation system.

### Requirements

Requirements are:
- Bash (with wget or curl installed)
- Java (up to 21 seems to be tested)
- Git
- Docker (not needed for the first script that you will write but needed in general for Nextflow)

Good to have:
If you are using it in Azure it is good to have you Azure Batch, Azure Storage, Virtual machine and network where all these features are seating configured together with your managed identities (credentials). Ask the RDM team for that.

### Download and install Nextflow

Execute the following in your terminal:
```bash
wget -qO- https://get.nextflow.io | bash
```

If you do not have wget but have curl, you could use the curl command:
```bash
curl -s https://get.nextflow.io | bash
```

Next, we make sure that the downloaded binary is executable:
```bash
chmod +x nextflow
```

Finally, ensure the nextflow executable is in your $PATH. The executable could be in `/usr/local/bin`, `/bin/`, etc...
```bash
sudo mv nextflow /usr/local/bin/
```

> Notice that these are the commands that we used in our devcontainer.json file to build our codespace.

### Docker

Please to install Docker follow this [link](https://docs.docker.com/get-started/get-docker/) and download the version that matches you OS.

### Nextflow in Windows

While Nextflow can run natively on Windows, its primary development and optimization are for Unix-based systems (Linux and macOS). Windows support is provided but may not be as smooth or feature-complete. We recommend to install Windows Subsystem for Linux (WSL). WSL allows you to run a Linux environment on Windows providing access to Unix-like tools and environments, enabling compatibility with Docker for containerized workflows, and resolving many possible compatibility issues related to the file system and paths.