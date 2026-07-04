# Overview

## Interpreter

A practical way to study a programming language is to build a program that can
run programs written in that language. Such a program that reads and evaluates a
program is called an **interpreter**.

## PLCC

PLCC, first mentioned in the previous chapter, is a powerful tool that can
generate such an interpreter. PLCC generates an interpreter based on a textual
description of the programming language we wish to design. We refer to the
textual description as a grammar.

The diagram below depicts the relationships among language designers,
programmers, and PLCC. Language designers write a grammar for the language they
are designing. They use PLCC to generate an interpreter for the language from
its grammar. Then programmers write programs in this language and use the
generated interpreter to run these programs.

```plantuml
@startuml
actor designer
actor programmer

artifact grammar [
    grammar<sub>lang</sub>
]

storage plcc

storage interpreter [
    interpreter<sub>lang</sub>
]

artifact program [
    program<sub>lang</sub>
]

label behavior

designer .> grammar : writes
grammar -> plcc
plcc ..> interpreter :generates
program -> interpreter
interpreter -> behavior
programmer .> program : writes
@enduml
```

In the course of this textbook, we will take on the role of a language designer.

## Grammar

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

The composition of the grammar read by PLCC reflects the typical interpreter's 
organization. As we can see in the figure below, the grammar is broken up in
three parts: lexical specification, syntactical specification, and semantic
specification. The next three chapters will go over each of these parts in
greater detail.

```plantuml
@startuml
file grammar {
    artifact lexspec as "lexical specification (regex)"
    artifact synspec as "syntactical specification (BNF)"
    artifact semspec as "semantic specification (e.g., Python)"
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

We will see that the programming language specification articulated in a grammar
is itself a small programming language. We could, in principle, write a
grammar for the PLCC specification and ask PLCC to generate an alternate version
of itself.
