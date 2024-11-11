# RNA-Seq workflow

Let's run a commonly used Nextflow pipeline to analise RNA-seq data ([nf-core/rnaseq](https://nf-co.re/rnaseq/3.17.0)).

This pipeline that we will run will cover the following 4 steps using diffrent coomonly used bioinformatics tools:

1. Indexes a transcriptome file
2. Quality control of the high throughput sequence data with **FastQC**
3. Quantification  of transcripts using **Salmon**
4. Creates a **MultiQC** report. MultiQC searches a given directory for analysis logs and compiles a easy-viwing HTML report.

This is based on this part of [Nextflow tutorial](https://training.nextflow.io/basic_training/rnaseq_pipeline/). There you can find the pipeline broken into the different pieces in a collection of 7 different scripts if you want to get into the details.

In this part of the tutorial you can also see that Nextflow allows the execution of a workflow project directly from a GitHub repository. This [GitHub repository](https://github.com/nextflow-io/rnaseq-nf) hosts a version of this tutorial workflow (first 4 steps with some test data). You can run it specifying the project name and executing each process in a Docker container (`with-docker` as parameter). The containers will be automatically downloaded and saved in the folder `$HOME/.nextflow`.

```groovy
nextflow run nextflow-io/rnaseq-nf -with-docker
```