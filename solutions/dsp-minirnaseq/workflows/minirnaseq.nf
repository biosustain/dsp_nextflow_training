/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { GFFREAD as GFF_TO_GTF          } from '../modules/nf-core/gffread/main'
include { GFFREAD as GFFREAD_TRANSCRIPTS } from '../modules/nf-core/gffread/main'
include { BOWTIE2_BUILD          } from '../modules/nf-core/bowtie2/build/main'
include { BOWTIE2_ALIGN          } from '../modules/nf-core/bowtie2/align/main'
include { SALMON_QUANT           } from '../modules/nf-core/salmon/quant/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_minirnaseq_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MINIRNASEQ {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    fasta          // path: genome FASTA file
    gff            // path: genome annotation GFF file
    multiqc_config
    multiqc_logo
    multiqc_methods_description
    outdir

    main:

    def ch_versions = channel.empty()
    def ch_multiqc_files = channel.empty()
    //
    // MODULE: Run FastQC
    //
    FASTQC(ch_samplesheet)
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.map{ _meta, file -> file })

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

    //
    // Collate and save software versions
    //
    def topic_versions = channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    def ch_collated_versions = softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${outdir}/pipeline_info",
            name:  'minirnaseq_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        )

    //
    // MODULE: MultiQC
    //
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    def ch_summary_params = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
    def ch_workflow_summary = channel.value(paramsSummaryMultiqc(ch_summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    def ch_multiqc_custom_methods_description = multiqc_methods_description
        ? file(multiqc_methods_description, checkIfExists: true)
        : file("${projectDir}/assets/methods_description_template.yml", checkIfExists: true)
    def ch_methods_description = channel.value(methodsDescriptionText(ch_multiqc_custom_methods_description))
    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml', sort: true))
    MULTIQC(
        ch_multiqc_files.flatten().collect().map { files ->
            [
                [id: 'minirnaseq'],
                files,
                multiqc_config
                    ? file(multiqc_config, checkIfExists: true)
                    : file("${projectDir}/assets/multiqc_config.yml", checkIfExists: true),
                multiqc_logo ? file(multiqc_logo, checkIfExists: true) : [],
                [],
                [],
            ]
        }
    )
    emit:multiqc_report = MULTIQC.out.report.map { _meta, report -> [report] }.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
