# RNA-Seq workflow

Let's run a commonly used Nextflow pipeline to analise RNA-seq data ([nf-core/rnaseq](https://nf-co.re/rnaseq/3.17.0)).

This training pipeline will cover the following 4 steps using commonly used bioinformatics tools:

1. Indexing a transcriptome file (with **Salmon**)
2. Quality control of the high throughput sequence data with **FastQC**
3. Quantification  of transcripts using **Salmon**
4. Creation of a **MultiQC** report. MultiQC searches a given directory for analysis logs and compiles an easy-viewing HTML report.

This is based on [Nextflow tutorial](https://training.nextflow.io/basic_training/rnaseq_pipeline/). There you can find the pipeline broken into 7 scripts if you want to build the pipeline step by step.

In this course, to be able to run this small pipeline we will clone the Nextflow training repository. If you do so you can also practice with hello training, fundamentals training based on the rnaseq pipeline and advanced training with all data, files and scripts needed.

First cloning with `git clone`:
```bash
git clone https://github.com/nextflow-io/training.git --depth 1
```

And then move to `training/nf-training`:
```bash
cd training/nf-training
```
For today we will run the last script (script7.nf) that contains all the parts we want to run (Indexing transcriptome file, fastQC of the files, Salmon for transcript quantification and MultiQC to see a final report).

> This pipeline requires **Docker** as every process is run inside a Docker container. In other words, we need an environment where the required operation system and software is installed with all dependencies. Nextflow uses generally containerization tools like Docker, Apptainer (formerly Singularity), or Conda environments to ensure reproducibility of the results.

We run script7.nf and we tell Nextflow to use Docker:
```{code-block} groovy
:caption: Running rnaseq pipeline (scrip7.nf)
nextflow run script7.nf -with-docker
```

After few minutes you should have run succesfully your first rnaseq pipeline on gut samples! Time to check your results and logs:
```bash
tree -a results
tree -a work
ls results
```

Let's have a look to the multiQC report by right clicking on it and `Show Preview`. 

> **MultiQC** is a tool that aggregates results from the pipeline steps (from all the softwares that is compatible with -  quite many!). In this case it shows some general statistics, fastQC results, and the Quantification information.

We could also specify to Nextflow that it needs to run with Docker adding this information in a config file. Let's create a config file named `course.config` and add the following:
```{code-block} groovy
:caption: nextflow.config
docker.enabled = true
```

Let's run again the workflow by calling our config file with Nextflow option `-c`:
```{code-block} groovy
:caption: Running rnaseq pipeline (scrip7.nf) with course.config
nextflow run script7.nf -c course.config
```

>You are are welcome to have a look to the file that was downloaded `nextflow.config`, to see what usually these files contain and realise how important they are to setup the environment for the nextflow runs. The config file `nextflow.config` must be in the same folder where you are running your main script (`main.nf`) otherwise you need to specify the location with `-c`
