# Instructions

## Opening the Nextflow environment
Go to [course website](https://github.com/biosustain/dsp_nextflow_training)

Click on button **Code** and click on the Codespaces tab. There click on **Create codespace**. Now your Nextflow environment will be built following the instructions in devcontainer.json file (i.e. installing Ubuntu, Docker, VSCode with Docker extension) with additional customization added in the Dockerfile (i.e, installing java and Docker dependencies).

To learn more about Github codespaces go [here](https://github.com/features/codespaces)

Now, Nextflow should be ready to run in your GitHub Codespace environment! Let's check that you have a fully functional environment.

```bash
:caption: Verify java installation:

java -version
```

```bash
:caption: Verify Nextflow installation:

nextflow -v
```

```bash
:caption: Nextflow information:

nextflow info
```

```bash
:caption: Verify Docker installation:

docker --version
```
