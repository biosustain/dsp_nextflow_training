# Build a small nf-core RNA-seq pipeline

In the tutorial you wrote a Nextflow pipeline from scratch. Real pipelines are rarely written like that: most bioinformatics pipelines are built from the [nf-core](https://nf-co.re/) **template** and from ready-made, tested nf-core **modules** (one module = one tool wrapped in a Nextflow process).

In this activity (about one hour) you will build `minirnaseq`, a small RNA-seq pipeline that:

1. checks the quality of the sequencing reads with **FastQC**
2. aligns the reads to the transcripts of a reference genome with **Bowtie2**
3. quantifies the transcripts with **Salmon**
4. summarises everything in a **MultiQC** report

At the end you will have a table of **transcript abundances** for each sample and a **MultiQC report** to revise.

> The design follows the prokaryotic mode of [nf-core/rnaseq](https://nf-co.re/rnaseq) (`--aligner bowtie2_salmon`), and we use the same test dataset: two paired-end RNA-seq samples of *Salmonella* Typhimurium SL1344 and a small subset of its genome.

Bacterial genes have no introns, so the reads can be aligned directly to the transcript sequences, and Salmon can count the reads aligned to each transcript. Salmon needs two reference files that we do not have yet: the transcript sequences and an annotation in GTF format. We get both from the genome (FASTA) and its annotation (GFF) with a small tool called **gffread**:

```text
reads (FASTQ) ───────> FastQC ─────────────────────────────────────────┐
                                                                       │
genome (FASTA) + annotation (GFF) ──gffread──> GTF + transcripts       │
                                                    │                  │
                                              Bowtie2 index            │
                                                    │                  │
reads (FASTQ) ─────────────────────────────> Bowtie2 alignment ────────┤
                                                    │                  │
                                                 Salmon ───────────────┴──> MultiQC report
                                                    │
                                          transcript abundances
```

## 0. Before you start (2 min)

Open your codespace and check that you have the tools we need. If you created your codespace before this course, create a new one so that you get the updated environment.

```bash
nextflow -v
nf-core --version
docker --version
```

Then go to the folder of the course repository, where we will create the pipeline:

```bash
cd /workspaces/dsp_nextflow_training
```

## 1. Create the pipeline from the nf-core template (5 min)

nf-core tools creates a new pipeline with all the nf-core structure (configuration, parameter validation, MultiQC, CI tests, documentation...) already in place:

```bash
nf-core pipelines create \
    --name minirnaseq \
    --description "A mini RNA-seq pipeline built in the DSP Nextflow course" \
    --author "Your Name" \
    --organisation dsp
```

> Without options, `nf-core pipelines create` opens an interactive app where you can also choose which parts of the template to include.

A new folder `dsp-minirnaseq` was created. It is already a git repository. Go inside and have a look:

```bash
cd dsp-minirnaseq
tree -L 2
```

The most important files for today are:

| File | What it contains
|------|-----------------
| `main.nf` | The entry point: reads the parameters, validates the inputs and calls the main workflow
| `workflows/minirnaseq.nf` | The main workflow, where we connect the processes. It already runs FastQC and MultiQC!
| `modules/nf-core/` | The nf-core modules installed in the pipeline (now `fastqc` and `multiqc`)
| `nextflow.config` | The parameters with their default values, and the profiles (e.g. `docker`, `test`)
| `nextflow_schema.json` | The description of every parameter, used to validate them and to build the `--help`
| `assets/schema_input.json` | The description of the columns of the samplesheet given with `--input`
| `conf/test.config` | The `test` profile: small test data to check that the pipeline works
| `conf/modules.config` | The options of each module (extra arguments, where to save the results)

> In the tutorial we saved the results with workflow outputs (`publish:` and the `output` block). The nf-core template still saves the results of each process with the `publishDir` directive, which is set for all processes in `conf/modules.config`.

## 2. Add the test data and run the template (10 min)

### Add the reference parameters

Our pipeline needs two new parameters: the genome sequence (`--fasta`) and its annotation (`--gff`). Open `nextflow.config` and add them in the `params` block, under `// References`:

```{code-block} groovy
:caption: nextflow.config
    // References
    genome                     = null
    fasta                      = null
    gff                        = null
```

Every parameter of an nf-core pipeline must also be described in `nextflow_schema.json`, otherwise the pipeline warns about it. nf-core tools adds the new parameters for us:

```bash
nf-core pipelines schema build --no-prompts
```

> Without `--no-prompts`, this command asks you about every change and offers to open a web editor where you can write the description and help text of each parameter.

### Use the nf-core/rnaseq prokaryotic test data in the test profile

Open `conf/test.config` and replace the `TODO` lines and the example input in the `params` block with the *Salmonella* test data:

```{code-block} groovy
:caption: conf/test.config
params {
    config_profile_name        = 'Test profile'
    config_profile_description = 'Minimal test dataset to check pipeline function'

    // Input data: Salmonella Typhimurium SL1344, as in the nf-core/rnaseq test_prokaryotic profile
    input = params.pipelines_testdata_base_path + 'rnaseq/samplesheet/prokaryotic/samplesheet_test.csv'

    // Genome references: Salmonella Typhimurium SL1344 (subset)
    fasta = params.pipelines_testdata_base_path + 'rnaseq/reference/prokaryotic/SL1344_sub.fasta'
    gff   = params.pipelines_testdata_base_path + 'rnaseq/reference/prokaryotic/SL1344_sub.gff3'
}
```

The codespace has 2 CPUs and 8 GB of memory, so lower the maximum resources that a process can use in the same file:

```{code-block} groovy
:caption: conf/test.config
process {
    resourceLimits = [
        cpus: 2,
        memory: '6.GB',
        time: '1.h'
    ]
}
```

Have a look at the [samplesheet](https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/samplesheet/prokaryotic/samplesheet_test.csv). It has one row per sample with the sample name and the two FASTQ files (forward and reverse reads), as in most nf-core pipelines.

### Run the template

Our pipeline already works! Let's run it with the `test` profile (the test data) and the `docker` profile (every process runs in its own container):

```bash
nextflow run . -profile test,docker --outdir results
```

Which processes were run? Have a look at `results/fastqc` and `results/multiqc`.

You also got a warning about the `strandedness` column of the samplesheet. The samplesheet was made for nf-core/rnaseq, and our `assets/schema_input.json` only knows the `sample`, `fastq_1` and `fastq_2` columns, so the extra column is ignored.

## 3. Install the nf-core modules (5 min)

We do not need to write the processes for gffread, Bowtie2 and Salmon: there are nf-core modules for them. You can search the modules on the [nf-core website](https://nf-co.re/modules) or with `nf-core modules list remote`.

```bash
nf-core modules install gffread
nf-core modules install bowtie2/build
nf-core modules install bowtie2/align
nf-core modules install salmon/quant
```

Each module was downloaded to `modules/nf-core/` and recorded in `modules.json`. Before using a module, check its inputs and outputs:

```bash
nf-core modules info salmon/quant
```

Open also `modules/nf-core/salmon/quant/main.nf`. Can you find the `input:` and `output:` blocks? Notice that most inputs are tuples like `tuple val(meta), path(reads)`: in nf-core, every file travels together with a `meta` map with information about the sample, e.g. `[id: 'SALM_REP1', single_end: false]`.

## 4. Connect the modules in the workflow (20 min)

### Pass the references to the workflow

In `main.nf`, the entry workflow (`workflow {`, at the end of the file) calls the `DSP_MINIRNASEQ` workflow, which calls our `MINIRNASEQ` workflow. We pass the two new parameters through both.

In `main.nf`, add `fasta` and `gff` to the inputs (`take:`) of `DSP_MINIRNASEQ` and to its call of `MINIRNASEQ`:

```{code-block} groovy
:caption: main.nf
workflow DSP_MINIRNASEQ {

    take:
    samplesheet // channel: samplesheet read in from --input
    fasta       // path: genome FASTA file
    gff         // path: genome annotation GFF file

    main:

    //
    // WORKFLOW: Run pipeline
    //
    MINIRNASEQ (
        samplesheet,
        fasta,
        gff,
        params.multiqc_config,
        ...
```

and, further down in the entry workflow, give the parameters to `DSP_MINIRNASEQ`:

```{code-block} groovy
:caption: main.nf
    DSP_MINIRNASEQ (
        PIPELINE_INITIALISATION.out.samplesheet,
        params.fasta,
        params.gff
    )
```

### Add the new steps to the workflow

Open `workflows/minirnaseq.nf`. First include the new modules next to the `FASTQC` and `MULTIQC` ones. We use gffread twice for two different jobs, so we include it twice with two different names (aliases):

```{code-block} groovy
:caption: workflows/minirnaseq.nf
include { GFFREAD as GFF_TO_GTF          } from '../modules/nf-core/gffread/main'
include { GFFREAD as GFFREAD_TRANSCRIPTS } from '../modules/nf-core/gffread/main'
include { BOWTIE2_BUILD                  } from '../modules/nf-core/bowtie2/build/main'
include { BOWTIE2_ALIGN                  } from '../modules/nf-core/bowtie2/align/main'
include { SALMON_QUANT                   } from '../modules/nf-core/salmon/quant/main'
```

Then add `fasta` and `gff` to the inputs of `MINIRNASEQ`, in the same order as in the call in `main.nf`:

```{code-block} groovy
:caption: workflows/minirnaseq.nf
    take:
    ch_samplesheet // channel: samplesheet read in from --input
    fasta          // path: genome FASTA file
    gff            // path: genome annotation GFF file
    multiqc_config
```

Now the main part. Add the following code right after the FastQC step (after the `ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip...)` line). Read the comments: what goes in and out of each step?

```{code-block} groovy
:caption: workflows/minirnaseq.nf
    //
    // MODULE: Convert the genome annotation from GFF to GTF with gffread
    //
    GFF_TO_GTF(
        channel.value([ [id: 'genome'], file(gff, checkIfExists: true) ]),
        []
    )
    ch_gtf = GFF_TO_GTF.out.gtf

    //
    // MODULE: Extract the transcript sequences from the genome with gffread
    //
    GFFREAD_TRANSCRIPTS(ch_gtf, file(fasta, checkIfExists: true))
    ch_transcripts = GFFREAD_TRANSCRIPTS.out.gffread_fasta

    //
    // MODULE: Build the Bowtie2 index of the transcripts
    //
    BOWTIE2_BUILD(ch_transcripts)

    //
    // MODULE: Align the reads to the transcripts with Bowtie2
    //
    BOWTIE2_ALIGN(
        ch_samplesheet,
        BOWTIE2_BUILD.out.index,
        ch_transcripts,
        false, // save_unaligned
        false  // sort_bam: Salmon needs the alignments of each read together
    )
    ch_multiqc_files = ch_multiqc_files.mix(BOWTIE2_ALIGN.out.log.map{ _meta, file -> file })

    //
    // MODULE: Quantify the transcripts from the alignments with Salmon
    //
    // Salmon reference: [ meta, index (not needed in alignment mode), GTF, transcripts ]
    ch_salmon_reference = ch_gtf
        .combine(ch_transcripts)
        .map { _meta, gtf, _meta2, transcripts -> [ [id: 'transcripts'], [], gtf, transcripts ] }
        .first() // a value channel, so it is reused for every sample
    SALMON_QUANT(BOWTIE2_ALIGN.out.bam, ch_salmon_reference)
    ch_multiqc_files = ch_multiqc_files.mix(SALMON_QUANT.out.results.map{ _meta, dir -> dir })
```

A few things to notice:

> - The reference files are wrapped in **value channels** (`channel.value(...)`, `.first()`). A value channel can be read again and again, so the same index and transcripts are used for every sample. A normal channel is consumed: with it, only the first sample would be quantified!
> - `[]` is used for an optional input that we do not need, e.g. Salmon does not need its own index because it reads the Bowtie2 alignments.
> - Every tool that MultiQC understands adds its log or result files to `ch_multiqc_files`, the channel that MultiQC reads.

### Set the options of the tools

The command line options of each tool are not written in the modules but in `conf/modules.config` (`ext.args`), so the same module can be reused in different pipelines. Add these settings inside the `process { }` block, before the `MULTIQC` settings:

```{code-block} groovy
:caption: conf/modules.config
    withName: GFF_TO_GTF {
        ext.args = '--keep-exon-attrs -F -T'
    }

    withName: GFFREAD_TRANSCRIPTS {
        ext.args   = '-w'
        ext.prefix = 'transcripts'
    }

    withName: 'GFF_TO_GTF|GFFREAD_TRANSCRIPTS|BOWTIE2_BUILD' {
        publishDir = [
            path: { "${params.outdir}/reference" },
            mode: params.publish_dir_mode
        ]
    }

    withName: BOWTIE2_ALIGN {
        ext.args = '--very-sensitive --no-discordant -k 200'
    }

    withName: SALMON_QUANT {
        ext.args = '--libType A'
    }
```

> - gffread converts the GFF to GTF (`-T`) and writes the transcript sequences (`-w`).
> - Bowtie2 reports up to 200 alignments per read (`-k 200`), so that Salmon can share the reads that map to several transcripts. These are the settings used by nf-core/rnaseq.
> - `--libType A` lets Salmon detect automatically if the library is stranded.
> - The reference files are saved in `results/reference`.

## 5. Run your pipeline (5 min)

```bash
nextflow run . -profile test,docker --outdir results -resume
```

Thanks to `-resume`, FastQC is not run again. How many processes were run now? How many times was `SALMON_QUANT` run, and why?

> If something fails, read the error message: Nextflow tells you which process failed, the command that was run and its work directory. Fix the code and run the same command again with `-resume`.

## 6. Explore the results (13 min)

```bash
tree -L 2 results
```

### Transcript abundances

Salmon writes one folder per sample. Have a look at the abundances of the first sample:

```bash
column -t results/salmon/SALM_REP1/quant.sf
```

| Column | Meaning
|--------|--------
| `Name` | Transcript name
| `Length` | Length of the transcript
| `EffectiveLength` | Length corrected for the fragment length (the positions where a fragment can start)
| `TPM` | Transcripts Per Million: abundance normalised by transcript length and sequencing depth, comparable between transcripts
| `NumReads` | Estimated number of reads coming from the transcript

Which transcript is the most abundant in each sample? Are the two replicates similar? Salmon also wrote `quant.genes.sf`, with the abundances per gene.

> These tables are the starting point of a differential expression analysis, e.g. with DESeq2 in R.

### MultiQC report

Open `results/multiqc/multiqc_report.html`: right click on it in the VSCode explorer and select **Show Preview** (or **Open with Live Server**).

- **General Statistics**: one line per sample with the main numbers of every tool
- **FastQC**: are the reads of good quality? Is there adapter content?
- **Bowtie2**: which percentage of the read pairs aligned to the transcripts?
- **Salmon**: which fragment length distribution did Salmon estimate?
- **Software versions** and **Workflow summary**: everything you need to report your analysis

Have a look also at `results/pipeline_info`: the execution report and timeline tell you how long each process took and how much CPU and memory it used.

## Going further

- Check your code with the Nextflow linter: `nextflow lint .`. The warnings about the `when` section come from the nf-core modules, not from your code.
- Check that your pipeline follows the nf-core guidelines: `nf-core pipelines lint`.
- Run the real nf-core/rnaseq pipeline on the same data and compare the results with yours (this one takes longer!). Its test profile asks for 4 CPUs, so first write a small config file that limits the resources to the codespace size, and give it to Nextflow with `-c`:

```bash
echo "process.resourceLimits = [cpus: 2, memory: '6.GB', time: '1.h']" > codespace.config
```

```bash
nextflow run nf-core/rnaseq -r 3.27.0 -profile test_prokaryotic,docker --outdir rnaseq_results -c codespace.config
```

- Learn more in the [nf-core documentation](https://nf-co.re/docs) and in the [Nextflow training](https://training.nextflow.io/).
