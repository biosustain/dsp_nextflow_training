# Nextflow fundamentals tutorial
For DTU-Biosustain and DTU-Bioenginnering

Print the current version, system and runtime:
```bash
:caption: Verify java installation:

nextflow info
```

Run hello.nf as it is, passing a parameter from the command line and after changing the code in the second process (rev $y) using –resume
nextflow run hello.nf
nextflow run hello.nf --greeting ‘Hello Albert’
nextflow run hello.nf --greeting ‘Hello Albert’ -resume
