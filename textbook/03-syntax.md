# Syntax

The second component in the interpreters that PLCC builds for us is called a
*parser*. Its role is to verify that the sequence of tokens produced by the
scanner forms a syntactically valid sentence in a given language. It is a
process reminiscent of ensuring that the rules governing how words are arranged
to create well-formed English sentences are being followed.

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
<List>          ::= <NUM:num> <ListTail>
<ListTail:Some> ::= COMMA <NUM:num> <ListTail>
<ListTail:None> ::=
```

Let's go over this specification. At the top, we recognize the lexical
specification. Below we find the syntactic specification described in
Backus-Naur form (BNF), a very common notation system for specifying the syntax
of programming languages. The first line of the syntactic specification says
that a list of numbers consists of a number followed by the rest of the list.
The next two lines say that the rest of the list is either at least one more
number preceded by a comma (the second line) or nothing (the third line).

## PLCC syntactic specification

### Basic rules

### Alternatives

### Zero or more

### One or more

### Separated by

## Back-Naur form

## References

## Going beyond

### Suggested readings
