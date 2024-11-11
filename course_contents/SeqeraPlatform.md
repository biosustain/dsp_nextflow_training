# Run Nextflow CLI with Seqera Platform visualizing and capturing logs

## Seqera platform

The Seqera Platform is a collaborative environment where pipelines and analysis results can be launched, cataloged, monitored, organized, and shared with colleagues.

Seqera platform can help us by:

1. giving researchers early access to pipelines and computational resources
2. promoting effective collaboration, 
3. standardizing and accelerating the generation of results, 
4. ensuring compliance and security providing the framework for reliable and reproducible pipeline execution 
5. allowing us to optimize and reduce computing and storage costs

## Run hello.nf script and follow the run in Seqera platform

First you need to create an account and create an access token. Later you need to export the token to your system:

```bash
export TOWER_ACCESS_TOKEN=copyandpastetokenfromtheSqeraPlatformhere
```

Lets's run our first nextflow script in Seqera with the addition of the -with-tower command:

```{code-block} groovy
:caption: hello.nf capturing logs in Seqera platform
nextflow run hello.nf -with-tower
```