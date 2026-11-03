# Types

## Type safety

Our approach to types is to create a language that is *strongly, statically
typed*. We add syntax to provide type information for values, and every program
is checked for proper type matching prior to evaluating the program.

A *statically typed* language is one in which type information can be determined
at "compile time" rather than at runtime. In this way, any type errors are found
before the program is evaluated. Saying that a language is *strongly typed*
means that there are no type "holes" in the system: the declared type of a
symbol (a variable or function parameter) dictates the types of the values that
can be bound to the symbol. Everything is type checked, without exception,
and all expressions must conform to type rules.

## Primitive types

Our typed language is based on the `SET` language. In the `SET` language, only
the integer value `0` is considered false, and all other values — including
`ProcVal`s — are true when used in conditional expressions. The Java programming
language, which is statically typed, requires that the test expression in an
`if` statement evaluates to a boolean. We follow this example in our typed
language by introducing *primitive types*, `int` and `bool`, corresponding to
integer and boolean expressed values, respectively. To implement this feature,
we add a new `BoolVal` subclass of the `Val` class. With this addition, we can
require that the test expression in an `if` expression be an instance of
`BoolVal`.

Observe that the `int` and `bool` types in our (as yet unnamed) language are
*not* the same as the corresponding types in Python, even though they are
closely related and have the same name.

Our objective is to associate a type with every instance of the class `Val`. An
`IntVal` has type `int`, and a `BoolVal` has type `bool`. The only other `Val`
object is a `ProcVal`, so we need a way to give a type to a `ProcVal`.

## Function type

When we define a function, we *declare* the types of each of the function's
formal parameters and the function's return type.

We use the notation

> $[ t_1, t_2, ... , t_n => t ]$

to represent the type of a function that has $n$ formal parameters of types
$t_1$, $t_2$, ... $t_n$, respectively, and that returns a value of type $t$.

For simplification, we do not permit the creation of new (named) types, so every
type is either an integer, boolean, or function.

## Syntax

A *type expression* is a syntactic category in our typed language that describes
a type:

```
<TypeExp:PrimTypeExp>   ::= <PrimType>
<TypeExp:ProcTypeExp>   ::= LBRACK <TypeExps> RARROW <TypeExp> RBRACK
<PrimType:BoolPrimType> ::= BOOL
<PrimType:IntPrimType>  ::= INT
<TypeExps>              **= <TypeExp> +COMMA
```

Here are some examples of type expressions:

1. `int`
2. `bool`
3. `[ bool, int => int ]`
4. `[ [ int => bool ], [ int, int => int ] => [ int, int => bool ] ]`
5. `[ => int ]`

Type expressions 1 and 2 describe primitive `int` and `bool` types,
respectively. Type expression 3 describes a function type that takes two
parameters of type `bool` and `int`, respectively, and that returns an `int`.
Type expression 4 describes a function type that takes two function parameters
of type `[ int => bool ]` and `[ int, int => int ]`, respectively, and that
returns a function of type `[ int, int => bool ]`. Type expression 5 describes a
function type that takes no parameters and that returns an `int`. Observe that
**any type expression that starts with a `[` must be a function type**.

Our typed language now requires that every function expression be annotated with
type expressions for each of the function's formal parameters — its *(declared)
formal parameter types* — and a type expression for the function's return value
— its *(declared) return type*. Together, these annotations completely define
the function's type, called (not surprisingly) the *defined type* of the
function.

The following examples show how to modify a function expression in the `SET`
language by adding type annotations so that it conforms to the `TYPE0` language
rules (refer to the next chapter for the start of the discussion of the `TYPE0`
language):

Consider the following function defined the `SET` language without any type
annotations:

```
proc(t) +(t,5)
```

The same function in the `TYPE0` language with type annotations is:

```
proc(t : int) : int +(t, 5) % defined type [ int => int ], return type int
```

This function has defined type `[ int => int ]` and returns a value of type
`int`.

Next, consider the function below defined in `SET` without type annotations:

```
proc(f, x) .f(x)
```

The same function in the `TYPE0` language with type annotations is written:

```
proc(f : [ int => int ], x : int) : int .f(x)
```

This function has defined type `[ [ int => int ], int => int ]` and returns a
value of type `int`.

When used in an expression, a function *application* is considered to have a
type equal to the *return type* of the function. For example, the type of the
following function application is `int`:

```
.proc(t : int) : int +(t, 5) (4)
```

The previous expression evaluations to `9`, an `int`.

We will shortly define grammar rules for the `TYPE0` language that parse such
expressions.

## Type error

**Every expression has a type. The type of a variable (**`VarExp`**) is the type
that is bound to the variable in the current type environment.** All variables
must have a type binding.

A *type error* is one of the following:

* an attempt to define a function whose declared return type does not match the
  type of the body of the function;

* an attempt to apply a non-function as a function;

* an attempt to apply a function to the wrong number of actual parameters;

* an attempt to apply a function to actual parameters whose types do not match
  the declared types of the corresponding formal parameters;

* an attempt to use a non-boolean as the controlling expression of an `if`
  expression;

* an attempt to have expressions of different types in the `then` and `else`
  parts of an `if` expression;

* an attempt to assign a value to a left-hand side variable in a `set`
  expression where the type of the variable does not match the type of the
  right-hand side expression.

In the above, we consider primitive functions such as `+`, `add1`, and `zero?`
as functions for the purposes of type checking. These primitive functions have
pre-defined function types.

Our static type checking implementation also detects errors where an identifier
is referred to in a particular expression without appearing on the left-hand
side of an enclosing `let` or `letrec` or in a top-level `define` — i.e., if the
identifier occurs free in the expression. It also detects errors where the same
identifier appears twice on the left-hand side of a `let` or `letrec` or if the
same identifier appears twice in the formal parameter list of a `proc`.

A variable is in *declaration position* if it occurs on the left-hand side of a
`define`, `let`, or `letrec` definition, or if it appears as a formal parameter
in a function definition. These occurrences determine the *defined type* of the
variable according to the following rules:

* The defined type of a variable appearing in declaration position in a
  `define`, `let`, or `letrec`  is the type of its right-hand side expression.

* The defined type of a variable appearing in a formal parameter list is its
  declared type in the function definition.

When a variable appears in an expression, the type of the variable is its
defined type using static scope rules.

Notice that static scope rules make it possible to determine the types of
variables that appear free in a function body — in other words, variables that
do not appear as function formal parameters.

Numeric literals all have type `int`. We predefine the identifiers `true` and
`false` to have type `bool`, with the obvious semantics in controlling
expressions of `if` expressions.

The type of a `let` or `letrec` expression is the type of the expression's body.

Observe that the expressed value of controlling expression in an `if` expression
can no longer be an `IntVal`, so an expression like

```
if 0 then 3 else 4
```

that we have seen in Language `SET` will not work in our typed language.

Since the type of a variable is determined by static scope rules, the only
"interesting" types are those of functions. We need to add syntax rules for
function definitions that permit us to declare the types of its formal
parameters and its return type.

## Reference

* "Type safety," Wikipedia, last modified November 1, 2026
  [https://en.wikipedia.org/wiki/Type_safety](https://en.wikipedia.org/wiki/Type_safety)
