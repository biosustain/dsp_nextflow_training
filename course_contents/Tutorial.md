# Nextflow fundamentals tutorial

## First enviroment verifications
Let's get some information about Nextflow. Print the current version, system and runtime:
```{code-block} groovy
:caption: Verify java installation:

nextflow info
```

## Running our first script

Let's run our first script, 'Hello World!' script. Open a new file in VSCode in the codespace and copy paste the following code. Save it as hello-world.nf.

```{code-block} groovy
:caption: hello-world.nf

#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to standard out
 */
// A process
process sayHello {

    //directives
    output:
        stdout
    
    // code block (here using bash)
    script: 
    """
    echo 'Hello World!'
    """
}

// the workflow
workflow {

    // emit a greeting
    sayHello()
}
```

As you can see, a Nextflow script involves two main types of core components: process/es and the workflow. Each process describes what operation(s) should be performed (print 'Hello World!'), while the workflow describes the dataflow logic that connects the various steps.

Let's try to run this code in your codespace:
```{code-block} groovy
:caption: Running hello-world.nf
nextflow run hello-world.nf
```

## Find the output and logs in the work directory

The first time you run a pipeline it will create a new directory called 'work'. In this directory all the logs and results of each process will be stored in a folder named with a random hexadecimal code.

To see the work folder structure
```bash
tree -a work
```

If we look inside the subdirectory, we find the following log files:

> - .command.begin: Metadata related to the beginning of the execution of the process task
> - .command.err: Error messages (stderr) emitted by the process task
> - .command.log: Complete log output emitted by the process task
> - .command.out: Regular output (stdout) by the process task
> - .command.sh: The command that was run by the process task call
> - .exitcode: The exit code resulting from the command

## Send the output to a file and save it on an specific folder

Let's write the output to a file, we need to change the bash code in the code block
```bash
echo 'Hello World!' > output.txt
```

Now in the directives the output get defined as an output file instead of stdout.
```groovy
output:
    path 'output.txt'
```

Run the pipeline again!
```groovy
nextflow run hello-world.nf
```
Find the output file in the work directory.

Now let's save the outputfile on an specific folder called 'results'.
```groovy
process sayHello {

    publishDir 'results', mode: 'copy'

    output:
        path 'output.txt'
```

Run the pipeline again!
```groovy
nextflow run hello-world.nf
```
Was the output file saved in there? Is it the same or different than the output file saved in the corresponding work directory?

## Add in variable inputs using a channel

Let's add some more flexibility by using an input variable, so that we can easily change the greeting.

This requires us to make a series of inter-related changes:

- Tell the process about expected variable inputs using the input: block
- Edit the process to use the input
- Create a channel to pass input to the process (more on that in a minute)
- Add the channel as input to the process call


### Input definition to the process block:

Adding an input definition:

```groovy
process sayHello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path "output.txt"
```

### Edit the process command to use the input variable

Changing the code to write the variable in the output file:
```bash
echo '$greeting' > output.txt
```
### Create an input channel

This needs to be done in the workflow, we need to set up that input in the workflow part.

Nextflow uses channels to feed inputs to processes and ferry data between processes that are connected together

```groovy
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello world!')

    // emit a greeting
    sayHello()
}
```

### Add the channel as input to the process call

Now we need to actually plug our newly created channel into the sayHello() process call.

```groovy
// emit a greeting
sayHello(greeting_ch)
```
And run the pipeline again!

```groovy
nextflow run hello-world.nf
```

## Relaunch a pipeline without repeating steps

A very useful option of nextflow is the -resume to launch a pipeline again without repeating identical steps. Very interesting if your pipeline had an error in one of the processes and you want to 

Run the workflow again with -resume
```groovy
nextflow run hello-world.nf -resume
```

## Use command line interface (CLI) parameters for inputs

We want to be able to specify the input from the command line, Nextflow has a built-in workflow parameter system called params, which makes it easy to declare and use CLI parameters.

```groovy
// create a channel for inputs
greeting_ch = Channel.of(params.greeting)
```

Run the pipeline! Let's greet på Dansk!

```groovy
nextflow run hello-world.nf --greeting 'Hej verden!'
```

> Notice one thing here, for parameters that apply to a pipeline, we use a double hyphen (--), 
> whereas we use a single hyphen (-) >for parameters that modify a specific Nextflow setting, 
> e.g. the -resume feature we used earlier.

## Add a second process

Now we introduce a second process that converts the text to uppercase (all-caps).

Here it is the code:

```groovy
/*
 * Use a text replace utility as we will do it in bash to convert the greeting to uppercase
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
    cat '$input_file' | tr '[a-z]' '[A-Z]' > UPPER-${input_file}
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

## Run Nextflow CLI with Seqera Platform visualizing and capturing logs

Run a Nextflow workflow with the addition of the -with-tower command:

```{code-block} groovy
:caption: hello.nf capturing logs in Seqera platform
nextflow run nextflow-io/hello -with-tower
```