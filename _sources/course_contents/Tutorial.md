# Nextflow fundamentals tutorial

Our first script is going to be the typical `"Hello World!"` script to start learning any programming language. Let's get hands on the code!

> This tutorial is written for Nextflow 26.10 (the version installed in the codespace). Check your version with `nextflow -v`.

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

    script:
    // code block (here using bash)
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

For now we only have `output` and `script` (the code block) in the process and only one process is called in the workflow block (`sayHello()`).

Let's try to run your first Nextflow script in your codespace:

```{code-block} groovy
:caption: Running hello.nf
nextflow run hello.nf
```

How do you feel? Success? :)

Notice that while running it you got some info:

1. Nextflow version
2. Script launched, and the run name and revision assigned to this run
3. Details about the run (e.g. the process run, its work directory, completion)

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

You may have also noticed that you get some .nextflow.log files with all Nextflow activity since you run the script. These ones accumulate until 10 files. To see the one corresponding to the latest run do a `nextflow logfile last` (or `less .nextflow.log`). Very useful for debugging as well!

## Sending the output to a file

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

## Publishing the results in a folder

Now let's save the output file on a specific folder called `results`. We will do that by declaring a **workflow output**: we tell the workflow which channels to `publish`, and we describe in an `output` block how to save them.

> The `work` directory is Nextflow's scratch space. Workflow outputs are the files you want to keep, and they are copied (or linked) from `work` into the output directory, which is `results` by default.

The workflow block gets two sections: `main:` with the code we already had, and `publish:` where we assign the output of `sayHello` to a workflow output that we name `greetings`:

```groovy
workflow {
    main:
    // emit a greeting
    sayHello()

    publish:
    greetings = sayHello.out
}
```

Then, at the end of the script (after the workflow block), we add the `output` block describing how to publish `greetings`:

```groovy
output {
    greetings {
        mode 'copy'
    }
}
```

Run the pipeline again!
```groovy
nextflow run hello.nf
```

Where was the output file saved now? Could you find it anywhere else? Notice the `Outputs:` summary printed at the end of the run and the `mode 'copy'`. Is your greeting message now in `.command.out`? 

> With `mode 'copy'` you are telling Nextflow that the results need to be just a copy of the results saved in the work directory. There are other modes (e.g. `symlink`, `link`, `move`) to modify the publishing behaviour. You can also change the output directory with `nextflow run hello.nf -output-dir my_results`.

> In older pipelines (and in many nf-core pipelines) you will find the `publishDir` directive inside each process doing the same job, e.g. `publishDir 'results', mode: 'copy'`. It still works, but workflow outputs are the recommended way for new pipelines.

## Adding variable inputs using a channel

Let's add some more flexibility by using an input variable, so that we can easily change the greeting message.

This requires us to make four changes:

### 1. Adding input definition to the process block:

Tell the process about expected variable inputs using the input block 

> The `val` qualifier accepts any data type. It can be accessed in the process script by using the specified input name.

```groovy
process sayHello {
    input:
    val greeting

    output:
    path 'output.txt'
```

### 2. Editing the process code to use the input variable

Changing the code to write the variable (containing our greeting) in the output file:

```bash
echo "${greeting}" > output.txt
```
### 3. Creating an input channel in the workflow block

> Nextflow uses **channels** to feed inputs to processes and ferry data between processes that are connected together. `channel.of` is a factory method to create channels

```groovy
workflow {
    main:
    // creating a channel for inputs
    greeting_ch = channel.of('Hello world!')

    // emitting a greeting
    sayHello()

    publish:
    greetings = sayHello.out
}
```

### 4. Adding the channel as input to the process call in the workflow block

Now we need to actually plug our newly created channel into the sayHello() process call.

```groovy
// emit a greeting
sayHello(greeting_ch)
```

And run the pipeline again!
```groovy
nextflow run hello.nf
```

## Relaunching a pipeline without repeating steps

> One of the core features of Nextflow is the ability to cache task executions and re-use them in subsequent runs to minimize duplicate work. Reentrancy as it is called in computation, is useful both for recovering from errors and when developing a pipeline.

In other words use the `-resume` option to run a pipeline again without repeating the processes that have already been completed without errors. 

```groovy
nextflow run hello.nf -resume
```
What happened? Did your `sayHello()` process run again? Notice that the work subdirectory referenced in the summary of the pipeline execution has not changed and contains all results files and logs from the previous run, this step has not run again.

## Command line interface (CLI) parameters for inputs

> Nextflow has a built-in workflow parameter system called **params**, which makes it easy to declare and use CLI parameters.

First we declare our pipeline parameters in a `params` block. Let's put it by the beginning of our script (after the `#!/usr/bin/env nextflow` line). Each parameter has a name and a type, here `String` because a greeting is a piece of text:

```groovy
/*
 * Pipeline parameters
 */
params {
    greeting: String
}
```

Now we are going to modify how the channel is created to get the greeting value from the CLI in the workflow block.
```groovy
// create a channel for inputs
greeting_ch = channel.of(params.greeting)
```

Run the pipeline without giving any greeting. What does Nextflow tell you?
```groovy
nextflow run hello.nf
```

Now let's greet på Dansk!
```groovy
nextflow run hello.nf --greeting 'Hej verden!'
```

> Notice one thing here, for parameters that apply to a pipeline, we use a double hyphen (--), 
> whereas we use a single hyphen (-) for parameters that modify a specific Nextflow setting, 
> e.g. the -resume feature.

How the result looks now? Very Danish?

Try also to misspell the parameter, e.g. `--greting 'Hej verden!'`. Because all parameters are declared in the `params` block, Nextflow can check the CLI parameters and stop before running anything.

Finally, we can give the parameter a default value, so that it is used when no `--greeting` is given in the CLI:
```groovy
params {
    greeting: String = 'Hello world!'
}
```

## Let's add a second process to our pipeline

Now we introduce a second process that converts the text to uppercase.

Here it is just an scheme for the code, please complete it yourself:

```groovy
/*
 * Let's convert the greeting to uppercase
 */
process convertToUpper {
    //define an input file
    input:

    output:
    // the output file should contain an indication that these is an uppercase file + "_" + input file name
    // Avoid spaces in the file name!

    script:
    // now we add the bash code to convert the greeting to uppercase
    // A way to do that in bash scripting is cat file | tr '[a-z]' '[A-Z]' > output
    // By the way do not add // (comments) inside the """ code block, they will be interpreted as bash
    """
    
    """
}
```
Let's modify the code in the workflow block to accomodate the second process.

Calling a process returns its output channel, so we can save it in a variable (`greeting_files`) and pass it as the input to the convertToUpper process. We also publish the uppercase files as a second workflow output:

```groovy
workflow {
    main:
    // create a channel for inputs
    greeting_ch = channel.of(params.greeting)

    // emit a greeting
    greeting_files = sayHello(greeting_ch)

    // convert the greeting to uppercase
    upper_files = convertToUpper(greeting_files)

    publish:
    greetings = greeting_files
    uppercase = upper_files
}

output {
    greetings {
        mode 'copy'
    }
    uppercase {
        mode 'copy'
    }
}
```

> You will also see the output of a process referred as `sayHello.out`, which is the same channel as `greeting_files` here. Assigning outputs to variables makes the dataflow easier to read.

Now let's say Good morning in portuguese!

```groovy
nextflow run hello.nf --greeting 'Bom dia!'
```

What happened now? How many processes have been run? Did your code edits work? How are your output files named and where were they saved?

## Let's run the script on a batch of input values

Workflows typically run on batches of inputs that are meant to be processed in bulk, so we want to upgrade the workflow to accept multiple input values.

`channel.of()` factory method is quite happy to accept more than one value. Imagine that these could be used to pass a list of genes, genomes or fasta files, etc ... to the next process.

There are different factory channels to create these channels. 

Here you have an example where I used factory `channel.fromFilePairs()` to package as a channel fastq files.
```groovy
params {
    reads: String = "${projectDir}/data/*_{1,2}.fq.gz"
}

workflow {
    main:
    read_pairs_ch = channel.fromFilePairs(params.reads, checkIfExists: true)
    read_pairs_ch.view()
}
```

`.view` is an operator. Operators transform the channels or, as here, just print their contents, so that you obtain the input files on your desired format. Other commonly used operators are `.map`, `.filter`, `.flatMap` or `.collect`.

Back into our channel. Please modify the following, where do you need to add that?
```groovy
// create a channel for inputs
greeting_ch = channel.of('Hello','Bonjour','Hola','Hej')
```

We want to ensure the output file names will be unique as they will be all written in the same folder `results`. Let's generate a file name dynamically so that the final file names will be unique. We need then to modify the code in the process `sayHello`:

```groovy
process sayHello {
    input:
    val greeting

    output:
    path "${greeting}-output.txt"

    script:
    """
    echo "${greeting}" > "${greeting}-output.txt"
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

Too many files in the same folder? Use the `path` directive in the `output` block to save each workflow output in its own subfolder of `results`:

```groovy
output {
    greetings {
        path 'greetings'
        mode 'copy'
    }
    uppercase {
        path 'uppercase'
        mode 'copy'
    }
}
```

## Taking a sample file with different inputs

Finally last modification to our script. Usually workflows start from a sample file. In Nextflow and in nf-core standards this is usually called `samplesheet.csv`, with a header line and one sample per row. We will create a file called `greetings.csv` for our example pipeline, with a `greeting` column and one greeting per row, and save it in a folder called `data`.

```bash
mkdir data
cd data
printf 'greeting\nHello\nBonjour\nHola\nHej\n' > greetings.csv
less greetings.csv
cd .. 
```

Does the file greetings.csv look as one header and one greeting per line? :) Then you are good to go on...

Now we need to set up a CLI parameter with a default value pointing to an input file. Let's replace the `greeting` parameter in the `params` block. The type is now `Path`, because the parameter is a file:

```groovy
/*
 * Pipeline parameters
 */
params {
    // Path to a CSV file with one greeting per row, under a `greeting` header
    input: Path = 'data/greetings.csv'
}
```

Then we need to build the channel. 

We use channel factory, `channel.fromPath()`, which has some built-in functionality for handling file paths. 

Furthermore, we're going to add the `.flatMap` operator to read each CSV file into its rows using `splitCsv(header: true)`: each row becomes a map from the header to the value, e.g. `[greeting: 'Hello']`. Finally, the `.map` operator picks the `greeting` value of each row, so we get a channel of individual greetings.

By now you should know where to add this piece of code:
```groovy
// create a channel for inputs from a CSV file
greeting_ch = channel.fromPath(params.input)
    .flatMap { csv -> csv.splitCsv(header: true) }
    .map { row -> row.greeting }
```

Ok, lets try this script one last time!

```groovy
nextflow run hello.nf -ansi-log false
```
Did you get the same results? Hopefully yes but now you used a `greetings.csv` that could be your `samplesheet.csv` file if you run a real biological pipeline.

Want to greet in other languages? Point the pipeline to another file with `--input path/to/another.csv`.

## Checking and formatting your code

Nextflow comes with a linter that checks your script for errors and deprecated syntax without running it:

```bash
nextflow lint hello.nf
```

It can also format your code following the Nextflow code style:

```bash
nextflow lint -format hello.nf
```

> The Nextflow extension for VSCode (already installed in the codespace) runs the same checks while you write: look for the underlined code and the Problems tab.

## Summary

By now you should have:
> Basic idea of how to build a simple workflow and manage inputs and outputs. You know how to provide the input values to the workflow via the CLI or a file. You know how to define your output files and how to save the results in an specific folder.
>
> More generally, you've learned how to use the essential components of Nextflow: 
> - **Channels**: contain the input of the workflows used by the processes. Channels connect processes with each other.
> - **Operators**: transform the content of channels by applying functions or transformations. Operators are usually applied on channels to get the input of a process in the desired format.
> - **Processes**: define the script or software that is run (e.g. a fastQC analysis on sequenced data).
> - **Workflows**: call the processes as functions with channels as input arguments, only processes defined in the workflow are run.
> - **Parameters**: declared in the `params` block, they are the inputs of your pipeline that can be changed from the CLI.
> - **Workflow outputs**: declared in the `publish:` section and the `output` block, they are the results saved in the output directory.

## Full script

Here you have you first nextflow script in full! Congratulations!

```{code-block} groovy
:caption: hello.nf
#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */
params {
    // Path to a CSV file with one greeting per row, under a `greeting` header
    input: Path = 'data/greetings.csv'
}

/*
 * Process 1: Use echo to print a greeting to an output file
 */
process sayHello {
    input:
    val greeting

    output:
    path "${greeting}-output.txt"

    script:
    // code block (here using bash)
    """
    echo "${greeting}" > "${greeting}-output.txt"
    """
}

/*
 * Process 2: Use a text replace utility as we will do it in bash to convert the greeting to uppercase
 */
process convertToUpper {
    input:
    path input_file

    output:
    // we modify the output file name
    path "UPPER-${input_file}"

    script:
    // now we add the bash code to convert the greeting to uppercase
    """
    cat "${input_file}" | tr '[a-z]' '[A-Z]' > "UPPER-${input_file}"
    """
}

workflow {
    main:
    // create a channel for inputs from a CSV file
    greeting_ch = channel.fromPath(params.input)
        .flatMap { csv -> csv.splitCsv(header: true) }
        .map { row -> row.greeting }

    // emit a greeting
    greeting_files = sayHello(greeting_ch)

    // convert the greeting to uppercase
    upper_files = convertToUpper(greeting_files)

    publish:
    greetings = greeting_files
    uppercase = upper_files
}

/*
 * Workflow outputs: how to save them in the output directory (`results` by default)
 */
output {
    greetings {
        path 'greetings'
        mode 'copy'
    }
    uppercase {
        path 'uppercase'
        mode 'copy'
    }
}
```

## Going further

The language keeps evolving. When you feel comfortable with the basics, have a look at:
- [Static typing](https://www.nextflow.io/docs/latest/static-typing.html): typed processes and workflows, and records instead of tuples (enabled with `nextflow.enable.types = true`).
- [Modules](https://www.nextflow.io/docs/latest/modules.html): install and reuse nf-core modules with `nextflow module install`.
