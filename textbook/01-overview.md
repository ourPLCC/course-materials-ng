# Overview

## Interpreter

A practical way to study a programming language is to build a program that can
run programs written in that language. Such a program that reads and evaluates a
program is called an **interpreter**.

## PLCC

PLCC, first mentioned in the previous chapter, is a powerful tool that can
generate such an interpreter. PLCC generates an interpreter based on a textual
description of the programming language we wish to design. We refer to the
textual description as a specification.

The diagram below depicts the relationships among language designers,
programmers, and PLCC. Language designers write a specification for the new language they
are designing. They use PLCC to generate an interpreter for the new language from
its specification. Then programmers write programs in this new language and use the
generated interpreter to run these programs.

```plantuml
@startuml
actor designer
actor programmer

artifact specification [
    specification
]

storage plcc

storage interpreter [
    interpreter
]

artifact program [
    program
]

label behavior

designer .> specification : writes
specification -> plcc
plcc ..> interpreter :generates
program -> interpreter
interpreter -> behavior
programmer .> program : writes
@enduml
```

In the course of this textbook, we will take on the role of a language designer.

## Language Specification

Most interpreters are built around three successive phases: lexical analysis,
syntactic analysis, and semantic analysis.

```plantuml
@startuml
start
partition interpreter {
    partition parser {
        partition scanner {
            -> string;
            :lexical analysis;
            -> tokens;
        }
        :syntactic analysis;
        -> parse tree;
    }
    :semantic analysis;
}
-> (behavior);
stop
@enduml
```

The composition of the specification read by PLCC reflects the typical interpreter's
organization. As we can see in the figure below, the specification is broken up in
three parts: lexical specification, syntactical specification, and semantic
specification.

Based on the lexical specification, PLCC generates a scanner whose main
responsibility is to convert a stream of characters (the source) into a stream
of tokens. For now, it suffices to say that a token adds a layer of abstraction
over text to simplify the job of the parser.

Based on the syntactical specification, PLCC generates a parser whose main
responsibility is to generate an abstract syntax tree. The syntax tree adds
another layer of abstraction to facilitate checking that the input corresponds
to a well-formed program and attaching meanings to that program.

Based on the semantic specification, PLCC generates an interpreter that performs
the actions programmed in the input according to the meaning imbued in said
specification.

The next few chapters will go over each of these parts of the specification in
greater detail.

```plantuml
@startuml
file "Specification File" {
    artifact lexspec as "lexical specification"
    artifact synspec as "syntactical specification"
    artifact semspec as "semantic specification"
}

file source

node interpreter {
    component parser {
        component scanner {
            component lexan as "lexical analysis"
        }
        component synan as "syntactical analysis"
    }
    component seman as "semantic analysis"
}

label behavior

lexspec -> lexan
synspec -> synan
semspec -> seman

lexspec -[hidden]-> synspec
synspec -[hidden]-> semspec

source --> lexan
lexan --> synan : tokens
synan --> seman : tree
seman --> behavior
@enduml
```

## Going beyond

Any program processing any input expressed in a text-based programming language
must perform lexical analysis, syntactic analysis, and semantic analysis. Such
programs include compilers, interpreters, and static analyzers (i.e., linters).
So the concepts described in this chapter apply to all such tools.

We will see that the language we use to define these specifications is itself a small programming language. We could, in principle, write a specification for the PLCC tool in its own language and ask PLCC to generate an alternate version of itself.
