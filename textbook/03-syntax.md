# Syntax

Assuming a proper specification is provided, the second component included in
our generated interpreters is called a *parser*. Its role is to verify that the
sequence of tokens produced by the scanner forms a syntactically valid sentence
in a given language. It is a process reminiscent of ensuring that the rules
governing how words are arranged to create well-formed English sentences are
being followed.

A language's **syntactic specification** defines the set of valid sentences for
that language. The syntactic specification builds on top of the language's
lexical specification by referring to its tokens. Here is our first example of a
valid PLCC specification for a list of comma-separated numbers.

```
# Lexical specification for a list of comma-separated numbers
skip  WHITESPACE '\s+'
token NUM        '\d+'
token COMMA      ','

%

# Syntactic specification for a list of comma-separated numbers
<List>     ::= <NUM> <ListTail>
<ListTail> ::= COMMA <NUM> <ListTail>
<ListTail> ::=
```

Let's go over this specification. At the top, we recognize the lexical
specification described in the previous chapter. Below, after the percent
symbol, we find a syntactic specification described in a dialect of Backus-Naur
form (BNF). The first actual line of the syntactic specification, after the
second comment, says that a list of numbers consists of a number followed by the
rest of list. The next two lines say that the rest of the list is either empty
(the third line) or at least one more number preceded by a comma these two items
followed by the rest of the list (the second line).

## PLCC syntactic specification

### Basic rules

As stated in the introduction of this chapter, syntactic specifications are
commonly written in BNF, a common notation system for specifying the syntax of
programming languages. This section describes PLCC's dialect of BNF. A BNF
specification builds on top of the language's lexical specification by referring
to its tokens.

Most rules in our BNF have the form `LHS ::= RHS`. The left-hand side (`LHS`)
names a single *non-terminal* symbol (e.g., `List` or `ListTail`). The
right-hand side (`RHS`) define the structure of that non-terminal symbol. The
`RHS` may contain tokens (also known as *terminal* symbols) and non-terminals.
Many of our symbols will be enclosed in a pair of angular brackets (`<` and
`>`). Non-terminal symbols in this textbook follow the PascalCase writing
format.

For instance, the second line of our first example of a syntactic specification
says that the non-terminal `ListTail` consists of a `COMMA` (a terminal symbol),
followed by a `NUM` (a second terminal symbol), and ending with `ListTail` (a
non-terminal symbol).

The non-terminal on the `LHS` of the *first* syntactic rule plays an important
role in our specification. We call that non-terminal the *start symbol*.

### Alternatives

It will soon become apparent that we must have the important capability to
provide alternative definitions for a particular non-terminal symbol. Each
alternative is defined on its own separate line with the same given non-terminal
symbol appearing on the `LHS`.

The last two lines of the example syntactic specification given at the beginning
of this chapter provides an illustration: The non-terminal `ListTail` has two
alternative definitions (one is empty, the other is not).

### One or more and the empty string

Another important definition capability is allowing sentences of arbitrary
length. We rely on recursion to provide this capability: The non-terminal on the
`LHS` may appear on the `RHS` of its definition.

The second line of the introductory example syntactic specification illustrates
this concept: The non-terminal `ListTail` is defined in terms of itself (the
symbol `ListTail` also appears on the `RHS`). The definition says that we can
substitute `ListTail` with the sequence consisting of a `COMMA`, followed by a
`NUM`, and ending with another `ListTail`. We can apply this substitution again
to replace (or match) the latter `ListTail` with another `COMMA`, `NUM`, and
`ListTail` sequence. To avoid infinite recursion, we need a base case, which is
provided by the definition appearing on the third line. This definition provides
an alternative definition for `ListTail`. It states that `ListTail` may be
nothing. That is, we can satisfy `ListTail` by matching no symbol at all (i.e.,
the empty string).

This recursive capability stresses the importance of being able to provide
alternative definitions.
