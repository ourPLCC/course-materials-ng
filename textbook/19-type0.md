# Language TYPE0

## Type syntax for function definitions

We define a language named `TYPE0` that is based on the `REF` language and that
implements type *syntax*. The type-checking semantics associated with the new syntax
will *not* be implemented in TYPE0.

We first require that a function definition — in the
`<proc>` grammar rule — declare the types of each of its formal parameters and
the return type of the function. Each of these declarations are given by a type
expression, described in the previous chapter, in the following grammar rules
related to a `<proc>`. Notice that these grammar rules are similar to the
original grammar rules for the `REF` language, with the exception that they
include type declarations.

```
<Proc>                  ::= PROC LPAREN <Formals> RPAREN COLON <TypeExp> <Exp>
<Formals>               **= <SYMBOL> COLON <TypeExp> +COMMA
```

These changes do *not* affect the behavior of the `eval` methods that define the
semantics of the `REF` language. Thus the resulting `TYPE0` language has the
same semantics as the `REF` language, except for the presence of `bool` values:
the type information in a program is simply ignored during evaluation.

A function definition in our `TYPE0` language now looks as follows:

```
define add2 = proc(x : int) : int add1(add1(x))
```

This definition says that the *declared type* of the formal parameter `x` is
`int` and that the *declared return type* of `add2` is `int`, so that the
*defined type* of `add2` is `[ int => int ]`.

Since we have made changes to our syntax, our expression parse trees have
additional structure, but because our `eval` methods are not affected by the
type information, the `eval` methods in the specification for the `REF` language
are entirely unchanged.

Notice, however, that we have not implemented any of our type rules, so no type
checking is taking place.

## True and false expressions

Our `TYPE0` language has two new expressions: a `TrueExp` and a `FalseExp`, with
obvious concrete and abstract syntax:

```
<Exp:TrueExp>           ::= TRUE
<Exp:FalseExp>          ::= FALSE
```

What should the `eval` method return for these classes? In Language `REF`, we
used an `IntVal` of zero to be false and everything else to be true. Once we
have syntax for `true` and `false` expressions in Language `TYPE0`, we introduce
corresponding semantics using the `Val` type `BoolVal` that represent the values
of these expressions. The `BoolVal` class is simply a Python wrapper class for
Python `bool` values. The code for the `BoolVal` class is in the
Python-specific specification file.

Once we have the `BoolVal` class, we can define the `eval` behavior for the
`TrueExp` and `FalseExp` classes. Here's the code for `TrueExp` — the code for
`FalseExp` is nearly identical:

```python
def eval(self, env):
    return BoolVal(True)
```

Obviously the `isTrue` Python method applied to a `BoolVal` object constructed
with `True` must return true (in Python), and similarly the `isTrue` method applied to a `BoolVal` object constructed with `False` must return false. The
`isTrue` method applied to *any* other value (either an `IntVal` or a `ProcVal`)
must throw an exception.

## Additional predicates

We can add a number of new primitives applied to `IntVal` arguments that return
`BoolVal` values, such as the following, with obvious meanings:

```
<?
<=?
>?
>=?
=?
<>?
```

The purpose of the `?` at the end of these is to remind you that they are
testing something and that they return Boolean values (i.e., they are
predicates*). We also change the value returned by the `zero?` primitive to a
`BoolVal`.

The following expressions evaluate as indicated:

Expression                 | Value
-|-
`<?(3, 3)`                 | false (actually, a false `BoolVal`)
`<=?(3, 3)`                | true
`<>?(x, y)`                | depends on the current bindings of `x` and `y`
`=?(proc(t) t, proc(u) u)` | exception — a `ProcVal` is not an `IntVal`
`if 1 then 2 else 3`       | exception — `1` is not a Boolean
`zero?(1)`                 | false
`zero?(0)`                 | true
`zero?(proc(t) t)`         | exception — a `ProcVal` is not an `IntVal`
