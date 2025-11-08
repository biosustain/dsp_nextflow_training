# RNA-Seq workflow

Let's run a commonly used Nextflow pipeline to analise RNA-seq data ([nf-core/rnaseq](https://nf-co.re/rnaseq/3.17.0)).

This pipeline will cover the following 4 steps using commonly used bioinformatics tools:

1. Indexes a transcriptome file
2. Quality control of the high throughput sequence data with **FastQC**
3. Quantification  of transcripts using **Salmon**
4. Creates a **MultiQC** report. MultiQC searches a given directory for analysis logs and compiles an easy-viewing HTML report.

This is based on this part of [Nextflow tutorial](https://training.nextflow.io/basic_training/rnaseq_pipeline/). There you can find the pipeline broken into different part as a collection of 7 scripts if you want to get into deeper on the code.

To be able to run this pipeline we will clone the training repository from Nextflow official training materials from Github. Here you can enjoy the hello training, their fundamentals training based on the rnaseq pipeline and the advanced training with all data, files and scripts needed.

First cloning with `git clone`:
```bash
git clone https://github.com/nextflow-io/training.git --depth 1
```


And then move to `training/nf-training`:
```bash
cd training/nf-training
```
Here you find a collection of 7 scripts where the rnaseq pipeline (a small version of it) is broken into the different parts. It is great training material and I recommend you go through if you want to keep learning Nextflow. For today we will run the last script that contains all the parts we want to run (Indexing transcriptome file, fastQC of the files, Salmon for transcript quantification and MultiQC to see a final report of our run).

> This pipeline requires Docker as every process is run inside a Docker container. On other words an environment where the required operation system and software is installed with all dependencies. Nextflow uses generally containerization tools like Docker, Singularity, or Conda to ensure reproducibility of the results.

We run script7.nf that contain all the parts we want to run. ANd we tell Nextflow to use Docker:
```{code-block} groovy
:caption: Running rnaseq pipeline (scrip7.nf)
nextflow run script7.nf -with-docker
```

After few minutes you should have run succesfully your first rnaseq pipeline! Time to check your results and logs:
```bash
tree -a results
tree -a work
ls results
```

Let's have a look to an interesting report that we get summarizing the different steps of the pipeline.
```bash
code results/multiqc_report.html
```
Then on the top right corner look for the icon `Show Preview`.

MultiQC report aggregates results from the pipeline steps (from all the softwares that is compatible with -  quite many). In this case it shows some general statistics, fastQC results, and the Quantification information.

We could also specify to Nextflow that it needs to run with Docker adding this information in a config file. Let's create a config file named `course.config` and add the following:
```{code-block} groovy
:caption: nextflow.config
docker.enabled = true
```

Let's run again the workflow by calling our config file with Nextflow option `-c`:
```{code-block} groovy
:caption: Running rnaseq pipeline (scrip7.nf) with course.config
sudo nextflow run script7.nf -c course.config
```

>You are are welcome to have a look to the file that was downloaded `nextflow.config`, to see what usually these files contain and realise how important they are to setup the environment for the nextflow runs. The config file `nextflow.config` must be in the same folder where you are running your main script (`main.nf`) otherwise you need to specify the location with `-c`
