# Introduction

Programming languages are fundamental tools for software developers. Their
design shapes the way we think about problems, express solutions, and organize
programs into maintainable systems.

## Why study programming languages?

Every programmer needs a deep understanding of programming languages to learn
them more easily, to use them more effectively, to evaluate their strengths and
weaknesses (particularly when assessing a new language), and to design new ones.

Most programmers think they'll never design a new programming language. However,
programming languages are one important tool of automation and abstraction. You
may never need to create a full-fledged, general-purpose language, but you may
need to design a special-purpose programming language (also called a
domain-specific language) that eases solving a narrow class of problems.

## Methodology

To deepen our understanding of programming languages, we are going to devise
some. We will start with a very simple language, and incrementally build on that
language to study increasingly more sophisticated ones. As we do, we will
explore core concepts that appear in many modern and classic programming
languages.

A programming language consists of two parts: syntax and semantics. **Syntax**
describes the notation we use to write programs in a particular language.
**Semantics** defines the meaning of programs written in a language; that is,
what a program does when we run it.

The syntax of a language is the programmer's interface to a language. From this
perspective, syntax is important. Poor syntax makes programming an onerous task.
An better syntax can make a language less error prone, easier to type, easier
to understand, and easier to maintain.

Semantics is the engine of a language. It establishes the expressive power of a
language. It is where we decide if a language support iterative statements,
conditional statements, exception handling, goto statements, functions,
procedures, closures, type checking, classes and objects, out parameters, in-out
parameters, passing parameters by reference, passing parameters by value,
continuations, parallelism, side-effects, unification, etc.

Because semantics embodies the core of a programming language, it is where we
want to spend most our time in this course. We are going to build many, rather
ugly, languages. But these languages will support important and powerful
features!

To ease this process, we are going to rely on a tool: **PLCC - Programming
Languages Compiler Compiler**. It will allow us to simplify the process of
building languages by automating the generation of their parsers, allowing us to
focus our efforts on implementing their semantics.
