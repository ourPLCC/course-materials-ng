# Interlude: PLCC invocation

## A quick tour

PLCC comes with the three main commands summarized in the following table.

Command      | Purpose
-|-
`plcc-scan`  | Scan the given input
`plcc-parse` | Parse the given input
`plcc-rep`   | Evaluate the given input

If you have come to this chapter having read chapters sequentially, you may only
be familiar with the first command. Please be patient; explanations about the
other two commands will come soon enough. This chapter focuses on *how* to
invoke these commands, not *what* they accomplish. This chapter mentions all
three commands because they share the same invocation scheme.

## Installation

This chapter assumes that PLCC is installed in your environment. To install PLCC
in your environment, please consult the official
[documentation](https://ourplcc.github.io/plcc-ng/latest/installation/).

## Three invocation modes

All three commands listed at the beginning of this chapter read some input and
produce some output depending on their role.
That input is, in general, a piece of code in a language *you* are designing.
When you run the command, you are likely doing one or both of the following things.

1. Is the specification for the design of your programming language correct?
2. Is the program you wrote in that designed language correct?

In addition to the regular input,
all commands also read the specification file for your programming language's
design. That is, it will affect how that regular input above is processed.
By default, these commands look for a specification file named
`spec.plcc`. You can override this choice with a command-line argument. A
subsequent section gives more details.

The regular input can be fed into these commands in one of three ways:

* Through a file
* Interactively
* Input redirection

For the rest of this chapter, we use the command `plcc-scan` as an example and
we assume that the lines

```
# Lexical specification for a list of comma-separated natural numbers
skip  WHITESPACE '\s+'
token NUM        '\d+'
token COMMA      ','
```

are contained in a file named `spec.plcc` and that we wish to process the input

```
1, 2, 3
```

The principles exposed here will apply to all three commands equally.

### Through a file

Assuming the input is stored in file called `prog`, we can then invoke the
command as follows:

```bash
plcc-scan prog
```

Then the output should look as follows:

```
prog:1:1 NUM '1'
prog:1:2 COMMA ','
prog:1:4 NUM '2'
prog:1:5 COMMA ','
prog:1:7 NUM '3'
```

Specifically for the scanner, assuming no errors, each line of output consists
of the name of the input file that was processed, followed by a pair of numbers
separated with colons, the identified token name, and extracted lexeme enclosed
in a pair of single quotes. The numbers identify the line and column where the
lexeme was located in the input file.

### Interactively

If we just type the command

```bash
plcc-scan
```

then it will print a welcome message and a prompt, and wait for some input to be
typed:

```
Enter input. Press ^D (EOF) when done.
>>>
```

At the prompt, we can then enter our input:

```
>>> 1, 2, 3
```

If we then type the enter key, the command will produce the now familiar output
followed by another prompt:

```
-:1:1 NUM '1'
-:1:2 COMMA ','
-:1:4 NUM '2'
-:1:5 COMMA ','
-:1:7 NUM '3'
>>>
```

Instead of a file name, each line of output now starts with the hyphen (minus sign)
character indicating that the input was entered interactively.

We can enter another string of characters to process, followed by the enter key
or finish our interaction with the command by pressing `d` while holding the
control key (denoted `^D` or Control-D).

### Input redirection

The third way to process some input is to use input redirection. If we type the
command

```bash
echo "1, 2, 3" | plcc-scan
```

then the following output will appear:

```
-:1:1 NUM '1'
-:1:2 COMMA ','
-:1:4 NUM '2'
-:1:5 COMMA ','
-:1:7 NUM '3'
```

Again each line starts with the hyphen because the input was not read from
a file.

### Typical usage

What situation calls for a particular invocation style? Here are some
suggestions.

If you are running the same test repeatedly, perhaps during a debugging
session, then you will probably want to use the "through a file" method (e.g.,
`plcc-scan in1.txt`).

If you conducting some manual testing, perhaps checking the behavior of a new
feature, then you will probably want to use the "interactive" method.

You might reserve the "redirection" method either for a small test (e.g.,
`echo "1, 2, 3" | plcc-scan`) or when needing to string two or more commands
together (e.g., `cat in1.txt in2.txt | plcc-scan`).

Another advantage of the "through a file" and "redirection" methods is that
your command shell likely has a command *history*. That means you can use
the up-arrow on your keyboard to locate an old command and then re-execute it
by hitting the enter key.

## Text convention

Most examples in this text will specify the input and give the output without
assuming a particular invocation style.

For instance, using our running example, the text will simply say that scanning
the input

```
1, 2, 3
```

with the specification

```
# Lexical specification for a list of comma-separated natural numbers
skip  WHITESPACE '\s+'
token NUM        '\d+'
token COMMA      ','
```

produces the following output

```
-:1:1 NUM '1'
-:1:2 COMMA ','
-:1:4 NUM '2'
-:1:5 COMMA ','
-:1:7 NUM '3'
```

You just have to remember that if you use the "through a file" method the
hyphen would be replaced by your file's name.

## Common command-line arguments

The three commands accept the command-line argument listed in the following
table.

Function                        | Short form  | Long form
-|-|-
Show the help message           | `-h`        | `--help`
Indicate the specification file | `-s <filename>` | `--spec=<filename>`

## Exercises

### Exercise 1

Invoke the scanner using all three invocation modes.

## Reference

* "plcc-scan," PLCC Command Line Interface, version 2.0,
  https://ourplcc.github.io/plcc-ng/2.0/cli/commands/plcc-scan/
