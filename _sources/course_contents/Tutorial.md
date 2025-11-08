# Nextflow fundamentals tutorial

Our first script is going to be the typical `"Hello World!"` script to start learning any programming language. Let's get hands on the code!

## Running our first script

Open a new file in VSCode in the codespace by clicking the New file icon or by typing in the terminal `code hello.nf` (nf is the extension for Nextflow pipeline scripts).

Then copy / paste the following code. Save the file as hello.nf.

```{code-block} groovy
:caption: hello.nf

#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to standard out
 */
// A process
process sayHello {

    output:
        stdout
    
    // code block (here using bash)
    script: 
    """
    echo "Your name says Hello World!"
    """
}

// the workflow
workflow {

    // emit a greeting
    sayHello()
}
```

Now let's have a look to the code. A Nextflow script involves two main types of core components: process/es and the workflow. 

Each process describes what operation(s) should be performed (in our case printing 'Hello World!'), while the workflow describes the dataflow logic that connects the various steps. 

For now we only have `output` and `code block` in the process and only one process is called in the workflow block (`sayHello()`).

Let's try to run your first Nextflow script in your codespace:

```{code-block} groovy
:caption: Running hello.nf
nextflow run hello.nf
```

How do you feel? Success? :)

Notice that while running it you got some info:

1. Nextflow version
2. Run tag assigned and DSL2 code version (Nextflow is based on DSL language which is based on Groovy)
3. Executor (local machine)
4. Details about the run (e.g. completion, processes run, where to find the logs)

## Find the output and logs in the work directory

The first time you run a pipeline it will create a new directory called `work`. In this directory all the logs and results of each process will be stored in a folder named with a random hexadecimal code.

Let's do an `ls -a` to list the contents of `work`. Or to see the entire work folder structure try `tree -a`:
```bash
ls -a work/<hexadecimal code here>
tree -a work
```
Spend some time identifying all the files produced in your first script.

If we look inside each subdirectory, we find the following log files:

> - .command.begin: Metadata related to the beginning of the execution of the process task
> - .command.err: Error messages (stderr) emitted by the process task
> - .command.log: Complete log output emitted by the process task
> - .command.out: Regular output (stdout) by the process task
> - .command.sh: The command that was run by the process task call
> - .command.run: Full script run by Nextflow to execute the process call
> - .exitcode: The exit code resulting from the command

As you wrote your results in the standard output, where do you think you will find your greeting message? Are there some files empty for this run? Why?

You may have also noticed that you get some .nextflow.log files with all Nextflow activity since you run the script. These ones accumulate until 10 files. To see the one corresponding to the latest run do a `less .nextflow.log`. Very useful for debugging as well!

## Send the output to a file and save it on an specific folder

Let's write the output to a file, we need to define the output in a different way and change the bash code in the code block.

Now in the output gets defined as a file instead of stdout. 
> The `path` qualifier allows you to provide input/output files to the process execution context.
```groovy
output:
    path 'output.txt'
```

We adapt the code block. Now the greeting message is directed into the file called `output.txt`.
```bash
echo 'Hello World!' > output.txt
```

Run the pipeline again!
```groovy
nextflow run hello.nf
```

Now go and find the output file in the `work` directory.

Now let's save the outputfile on an specific folder called `results`. We will do that by specifying in the directives the results folder using the directive `publishDir`.

> Directives are optional settings that affect the execution of the current process.

```groovy
process sayHello {

    publishDir 'results', mode: 'copy'

    output:
        path 'output.txt'
```

Run the pipeline again!
```groovy
nextflow run hello.nf
```

Were was the output file saved now? Could you find it anywhere else? Notice the `mode: 'copy'`. Is your greeting message now in `.command.out`? 

> With `mode: 'copy'` you are telling Nextflow that the reults need to be just a copy of the results saved in the work directory. There are other mode types to modify the publishDir behaviour. 

## Add in variable inputs using a channel

Let's add some more flexibility by using an input variable, so that we can easily change the greeting message.

This requires us to make few changes:

1. Tell the process about expected variable inputs using the input block
2. Edit the process to use the input value (in the process block)
3. Create a channel to pass input to the process (more on that in a minute)
4. Add the channel as input to the process call (in the workflow block)

### 1. Input definition to the process block:

Adding an input definition. 

> The `val` qualifier accepts any data type. It can be accessed in the process script by using the specified input name.

```groovy
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path "output.txt"
```

### 2. Editing the process command to use the input variable

Changing the code to write the variable (containing our greeting) in the output file:

```bash
echo "$greeting" > output.txt
```
### 3. Creating an input channel

This needs to be done in the workflow block.

Nextflow uses channels to feed inputs to processes and ferry data between processes that are connected together

```groovy
workflow {

    // creating a channel for inputs
    greeting_ch = Channel.of('Hello world!')

    // emitting a greeting
    sayHello()
}
```

### 4. Adding the channel as input to the process call

Now we need to actually plug our newly created channel into the sayHello() process call.

```groovy
// emit a greeting
sayHello(greeting_ch)
```

And run the pipeline again!
```groovy
nextflow run hello.nf
```

## Relaunch a pipeline without repeating steps

> One of the core features of Nextflow is the ability to cache task executions and re-use them in subsequent runs to minimize duplicate work. Reentrancy as it is called in computation, is useful both for recovering from errors and when developing a pipeline.

In other words use the `-resume` option to run a pipeline again without repeating the processes that have already been completed without errors. 

```groovy
nextflow run hello.nf -resume
```
What happened? Did your `sayHello()` process run again? Notice that the work subdirectory referenced in the summary of the pipeline execution has not changed and contains all results files and logs from the previous run, this step has not run again.

## Use command line interface (CLI) parameters for inputs

> Nextflow has a built-in workflow parameter system called params, which makes it easy to declare and use CLI parameters.

So try to specify the input from the command line. For that you need to modify how the channel is created to get now the greeting value from the CLI in the workflow block.
```groovy
// create a channel for inputs
greeting_ch = Channel.of(params.greeting)
```

Run the pipeline! Let's greet på Dansk!
```groovy
nextflow run hello.nf --greeting 'Hej verden!'
```

> Notice one thing here, for parameters that apply to a pipeline, we use a double hyphen (--), 
> whereas we use a single hyphen (-) for parameters that modify a specific Nextflow setting, 
> e.g. the -resume feature we used earlier.

How the result looks now? Very Danish?

## Let's add a second process to our pipeline

Now we introduce a second process that converts the text to uppercase.

Here it is just an scheme for the code, please complete it yourself:

```groovy
/*
 * Let's convert the greeting to uppercase
 */
process convertToUpper {

    // directives
    //publish a directory for results

    //define an input file
    input:
        
    // the output file should contain an indication that these is an uppercase message + "_" + input file name
    // Avoid spaces in the file name!
    output:

    // now we add the bash code to convert the greeting to uppercase
    // A way to do that in bash scripting is cat file | tr '[a-z]' '[A-Z]' > output
    // By the way do not add // (comments in your script block) they will be interpreted
    script:
    """
    
    """
}
```
Let's modify the code in the workflow block to accomodate the second process.

The output of the sayHello process is automatically packaged as a channel called `sayHello.out`, so all we need to do is pass that as the input to the convertToUpper process.

```groovy
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of(params.greeting)

    // emit a greeting
    sayHello(greeting_ch)

    // convert the greeting to uppercase
    convertToUpper(sayHello.out)
}
```

Now you are ready to greet på Dansk igen!

```groovy
nextflow run hello.nf --greeting 'Hej verden!'
```

What happened now? How many processes have been run? Did your code edits work? How are your output files named and where were they saved?

## Let's run the script on a batch of input values

Workflows typically run on batches of inputs that are meant to be processed in bulk, so we want to upgrade the workflow to accept multiple input values.

`Channel.of()` factory we've been using is quite happy to accept more than one value. Imagine that these could be used to pass a list of genes, genomes or fasta files ... to the next process.

There are different factory channels to create these channels. 

Here you have an example where I used factory `Channel.fromFilePairs()` to package as a channel fastq files.
```groovy
params.reads = "$projectDir/data/*_{1,2}.fq.gz"

Channel
    .fromFilePairs(params.reads, checkIfExists: true)
    .toSortedList( { a, b -> a[0] <=> b[0] } )
    .flatMap()
    .set { read_pairs_ch }
    read_pairs_ch.view()
```

`.toSortedList`, `.flatMap`, `.set`, `.view` are operators to transform the channel and obtain the input files on your desired format.

Back into our channel. Please modify the following, where do you need to add that?
```groovy
// create a channel for inputs
greeting_ch = Channel.of('Hello','Bonjour','Hola','Hej')
```

We want to ensure the output file names will be unique as they will be all written in the same folder `results`. Let's generate a file name dynamically so that the final file names will be unique. We need then to modify the code in the process `sayHello`:

```groovy
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path "${greeting}-output.txt"

    script:
    """
    echo "$greeting" > "${greeting}-output.txt"
    """
}
```

Let's run the script again. But hang on, to expand the logging to display one line per process call to have a closer look to what is going on, just add `-ansi-log false` to the command.

```groovy
nextflow run hello.nf -ansi-log false
```

Did you see something different in the summary of the nextflow run?

Check the results folder and the output files:
```bash
tree results
less results/Hello-output.txt
less results/Hej-output.txt
...
```
## Take a file source of input values (a sample file)

Finally last modification to our script. Usually workflows start from a sample file. In Nextflow and in nf-core standards this is usually called `samplesheet.csv`. We will create a file called `greetings.csv` for our example pipeline and save it in a folder called `data`.

```bash
mkdir data
cd data
echo "Hello,Bonjour,Hola,Hej" > greetings.csv
less greetings.csv
cd .. 
```

Does the file greetings.csv look as greetings separated per commas? :) Then you are good to go on...

Now we need to set up a CLI parameter with a default value pointing to an input file. Let's put that piece of code by the bginning of our script:

```groovy
/*
 * Pipeline parameters
 */
params.input_file = "data/greetings.csv"
```

Then we need to build the channel. 

We use channel factory, `Channel.fromPath()`, which has some built-in functionality for handling file paths. 

Furthermore, we're going to add the `.splitCsv()` operator to make Nextflow parse the file contents accordingly, as well as the `.flatten()` operator to turn the array element produced by `.splitCsv()` into a channel of individual elements.

By now you should know where to add this piece of code:
```groovy
// create a channel for inputs from a CSV file
greeting_ch = Channel.fromPath(params.input_file)
                     .splitCsv()
                     .flatten()
```

Ok, lets try this script one last time!

```groovy
nextflow run hello.nf
```
Did you get the same results? Hopefully yes but now you used a `greetings.csv` that could be your `samplesheet.csv` file if you run a real biological pipeline.

## Summary

> Basic idea of how to build a workflow and manage inputs and outputs. You know how to provide the input values to the workflow via the CLI or a file. You know how to define your output files and how to save the results in an specific folder.
>
> More generally, you've learned how to use the essential components of Nextflow: 
> - **Channels**: contain the input of the workflows used by the processes. Channels connect processes with each other.
> - **Operators**: transform the content of channels by applying functions or transformations. Operators are usually applied on channels to get the input of a process in the desired format.
> - **Processes**: define the script or software that is run (e.g. a fastQC analysis on sequenced data).
> - **Workflows**: call the processes as functions with channels as input arguments, only processes defined in the workflow are run.

## Full script

Here you have you first nextflow script in full! Congratulations!

```{code-block} groovy
:caption: hello.nf
#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */
params.input_file = "data/greetings.csv"

/*
 * Process 1: Use echo to print 'Hello World!' to an output file
 */
process sayHello {
    //directives
    publishDir 'results', mode: 'copy'

    input:
        path input_file

    output:
        path "${greeting}-output.txt"

    script:
    """
    echo "$greeting" > "$greeting-output.txt"
    """
}

/*
 * Process 2: Use a text replace utility as we will do it in bash to convert the greeting to uppercase
 */
process convertToUpper {

    publishDir 'results', mode: 'copy'

    input:
        path input_file

    // we modify the output file name
    output:
        path "UPPER-${input_file}"

    // now we add the bash code to convert the greeting to uppercase
    script:
    """
    cat "$input_file" | tr '[a-z]' '[A-Z]' > UPPER-${input_file}
    """
}

workflow {

    // create a channel for inputs from a CSV file
    greeting_ch = Channel.fromPath(params.input_file)
                     .splitCsv()
                     .flatten()

    // emit a greeting
    sayHello(greeting_ch)

    // convert the greeting to uppercase
    convertToUpper(sayHello.out)
}
```
