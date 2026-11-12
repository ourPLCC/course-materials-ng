# Language TYPE1

## Type of an expression

Now that we have built the syntax for type expressions and incorporated it into
our grammar, we begin to implement type checking. Our strategy is to determine
the type of any expression, making type checks along the way.

Our first step is to define `Type` as a *semantic* entity in our implementation.
We implement `Type` as an abstract class with three subclasses:

* `IntType`
* `BoolType`
* `ProcType`

These correspond to the three classes that extend the `Val` class. Observe that
`Val` objects are used to evaluate expressions, whereas `Type` objects are used
for type checking. They serve similar purposes but are used in different ways.

Neither `BoolType` nor `IntType` has any attributes. A `ProcType` object has two
attributes:

* `paramTypeList`
* `returnType`

An expression is of type `IntType` if it evaluates to an integer. A similar reasoning applies for
a `BoolType`.

When we evaluate an expression, we use an environment to determine its expressed
value. When we are doing type checking, we do not care what the expressed value
actually is: only its type matters.

## Type environment

Our approach is to evaluate the type `Type` of an expression, doing type checks
of sub-expressions along the way. If there are no type errors, we can then
evaluate the value (`Val`) of the expression and return this value as we have
done before.

First, when we encounter a variable in an expression, we want to determine the
type of that variable. If the variable is a formal parameter in the body of a
function, its type is determined by the type declaration of the formal parameter.
For any other variable, its type can be determined using static scope rules.
This strategy suggests that we have a way of binding the variable to its type
during type checking in a way that is similar to binding the variable to its
value during expression evaluation. We achieve this by creating a *type
environment* that is almost identical to a value environment that we have been
using so far, except that our type environment binds variables to types rather
than to values.

The definitions of the classes relating to type environments are given in the
specification.

Since most of our type checking rules relate to type equality, we must define
what it means for two types to be equal. There are only three basic types,
and for each of them we define a `checkEquals` method. This method silently
returns if the types are the same, otherwise it calls the static `typeMismatch`
method in the `Type` class; this method raises a runtime exception with an
appropriate message.

## Primitive types

The two primitive types are simple. For the `BoolType` class, the `checkEquals`
method is defined as follows:

```python
def checkEquals(self, t):
    t.checkIntType(self)

def checkBoolType(self, t):
    pass    # this BoolType equals any other BoolType
```

The default `checkBoolType` method in the `Type` class — defined for all other
types except for `BoolType` — raises a type mismatch exception.

A similar definition works for the `IntType`.

## Function types

We are left to define `checkEquals` for the `ProcType` class. This is easy: two
`ProcType` objects are equal if they both have the same number of formal
parameter types and these formal parameter types are pairwise equal (in the
proper order), and if they both have the same return type.

Here is the definition of `checkEquals` in the `ProcType` class:

```python
def checkEquals(self, t):
    t.checkProcType(self)

def checkProcType(self, t):
    self.returnType.checkEquals(t.returnType)
    Type.checkEqualTypes(self.paramTypeList, t.paramTypeList)
```

The `checkEqualTypes` static method in the `Type` class is straight-forward:
first check for equal sizes; then iterate through both of the lists, checking
pairwise for type equality.

```
@staticmethod
def checkEqualTypes(typeList1, typeList2):
    if len(typeList1) != len(typeList2):
        raise LanguageError("argument number mismatch")
    for t1, t2 in zip(typeList1, typeList2):
        t1.checkEquals(t2)
```

## Logical primitives

At this point we can also add primitives operations for `and`, `or`, and `not`.

```
<Prim:AndPrim>          ::= ANDOP
<Prim:OrPrim>           ::= OROP
<Prim:NotPrim>          ::= NOTOP
```

Here is the `apply` method for an `AndPrim` object:

```python
def apply(self, args):
    if len(args) != 2:
        raise LanguageError("two arguments expected")
    b0 = args[0].boolVal().val
    b1 = args[1].boolVal().val
    return BoolVal(b0 and b1)
```

It is easy to see how the `apply` method should be implemented for the other two
primitives `or` and `not`.

## Primitive types

Although primitives are not functions (you cannot bind a variable to `add1`, for
example), they do have specific type behaviors that can be described in terms of
function types. The `+` primitive behaves like `[ int, int => int ]`, and the
`add1` primitive behaves like `[ int => int ]`. Each of the primitives are
associated with a `ProcType` that is used for type checking. We define these
types in the `Type` class as static instance variables.

Rather than building each of these types by hand with constructors, we define,
in the `Type` class, a series of static methods that returns each of needed
type signatures. The table below displays the method names and the
interpretations of the type signature they each return:

Method name | Type interpretation
-|-
`ii_i`      | `[ int, int => int ]`
`i_i`       | `[ int => int ]`
`ii_b`      | `[ int, int => bool ]`
`i_b`       | `[ int => bool ]`
`bb_b`      | `[ bool, bool => bool ]`
`b_b`       | `[ bool => bool ]`

The `definedType` method in the `Prim` class asks the primitive object what its
function type is, and the object calls the appropriate static method from among
the ones defined in the `Type` class. For example, in the `AddPrim` class,
`definedType` returns the signature defined by `ii_i`:

```python
def definedType(self):
    return Type.ii_i()
```

When declaring the formal parameter types of functions and processing `let` and
`letrec` expressions, we ensure that there are no duplicate variable names using
the `init` hook during parsing.

## Implementation

While the type environment classes are similar to those for expression
environments, it is unnecessary to use references, since we never modify the
type of a variable. Therefore type environments are similar to the environment
implementation in language `V6`. The essential changes are to replace `Var` with
`Type`, `Env` with `TypeEnv`, and `Binding` with `TypeBinding`.

## Type-check expressions

We are now prepared to write the code to type-check expressions. We need to
initialize a top-level type environment, which we call `initTypeEnv`.
This happens in the `Program` class, where we also define the top-level
expression environment.

```python
tenv = TypeEnv.initTypeEnv()
```

In the `Eval` class's `_run` method, we type-check by applying the `evalType`
method on the `exp` object — the "program" that we are to evaluate. The actual
return value of this call is irrelevant, since its purpose is simply to carry
out type checking prior to expression evaluation. If the type checking succeeds,
the `_run' method returns the string representation of the value of the
expression.

```python
def _run(self):
    self.exp.evalType(Program.tenv)     # type check first
    return str(self.exp.eval(Program.env))
```

The type of a `LitExp` is straightforward:

```python
def evalType(self, tenv):
    return Type.intType()
```

So are the types of a `TrueExp` and a `FalseExp`. For both the `TrueExp` and
`FalseExp` classes, we have:

```python
def evalType(self, tenv):
    return Type.boolType()
```

The type of a `VarExp` looks up the type of the variable in the type environment
and returns the result:

```python
def evalType(self, tenv):
    return tenv.applyTypeEnv(self.symbol.lexeme)
```

The type of a `LetExp` involves checking the left-hand side variable list for
duplicates (done during parsing), determining the types of the right-hand side
expressions using the current type environment, extending the current type
environment by binding the variables to the types of the right-hand side
expressions, and evaluating the type of the `let` body using this extended
environment:

```python
def evalType(self, tenv):
    ntenv = self.letDecls.addTypeBindings(tenv)
    return self.exp.evalType(ntenv)
```

Most of the work is done in the `addTypeBindings` method in the `LetDecls`
class, which we show here:

```python
def addTypeBindings(self, tenv):
    typeList = [e.evalType(tenv) for e in self.expList]
    return tenv.extendTypeEnv(TypeBindings(self.symbolList, typeList))
```

To determine the defined type of a function, we need to give semantic meaning to
the type expressions used to declare the types of a function's formal parameters
and return type. Specifically, we need to take a type expression given by the
`<typeExp>` grammar rules and evaluate its `Type`: in other words, the semantics
of a type expression is its `Type`. This is parallel to taking a value
expression given by `<exp>` grammar rules and evaluating its `Val`. Both of
these evaluations are examples of semantics.

For each type expression, we implement a `toType` method that returns the
corresponding instance of `Type`. One thing to observe is that a type expression
does not involve any variables, so there is no need to keep track of a type
environment.

For example, a type expression of the form `[ int => bool ]` would evaluate to a
`ProcType`, and a type expression of the form `int` would evaluate to a
`IntType`.

Here is the definition of `toType` for the `PrimTypeExp` class (representing
either an `int` or a `bool`) in the specification:

```
PrimTypeExp
%%%
def toType(self):
    return self.primType.toType()
%%%
```

For the `BoolPrimType` class, which corresponds to grammar rules for the `true`
and `false` tokens, we simply return `boolType`.

```
BoolPrimType
%%%
def toType(self):
    return Type.boolType()
%%%
```

Similar remarks apply to `IntPrimType`.

For a \verb'ProcTypeExp', we

1. determine the types (using the `toType` method) of the (formal parameter)
   type expressions that appear to the left of the "`=>`" token and insert them
   into a list of `Type` objects,

2. determine the type of the (return) type expression that appears to the right
   of the "`=>`" token, and then

3. construct the appropriate `ProcType` object:

```
ProcTypeExp
%%%
def toType(self):
    return ProcType(self.typeExps.toTypes(), self.typeExp.toType())
%%%
```

The `toTypes` method in the `TypeExps` class is straightforward, iterating over
its `typeExpList` and calling `toType` on each of its type expressions:

```
TypeExps
%%%
def toTypes(self):
    return [te.toType() for te in self.typeExpList]
%%%
```

We are now in a position to determine the *defined type* of a `proc` expression.
By defined type, we mean the type of the function (a `ProcType`) as determined
by the declared types of each of the formal parameters and the declared return
type. For example,

```
proc(x : int) : bool ...
```

has a formal parameter of declared type `int` and a declared return type of
`bool`, so the defined type of this function is `[ int => bool ]`. **The defined
type of a function is not dependent on the type environment in which the
function expression appears, nor on the names of the formal parameters.**

However, the type of the function *body* is dependent on the type environment in
which the function is evaluated, since the function body may have variables that
are free with respect to the function's formal parameters but that are bound to
types defined in an enclosing environment. One of our type checks is to ensure
that the function's declared return type is the same as the type of the function
body.

The `definedType` method in the `Proc` class evaluates the function's defined
type, which must be a `ProcType`: it gets the declared types of the formal
parameters from the `Formals` object and the declared return type from the
function's `typeExp`. The defined type is determined exclusively by the declared
types of the formal parameters and the function's declared return type.

```
Proc
%%%
def definedType(self):
    # the type from the annotations alone; the body is not checked
    return ProcType(self.formals.formalTypeList(), self.typeExp.toType())
%%%
```

The `Formals` class defines the `formalTypeList` method:

```
Formals
%%%
def formalTypeList(self):
    return [texp.toType() for texp in self.typeExpList]
%%%
```

We are now ready to define `evalType` in the `Proc` class:

```python
def evalType(self, tenv):
    # the declared return type of the proc
    declaredReturnType = self.typeExp.toType()
    # bind the formal parameters to their declared types
    ntenv = tenv.extendTypeEnv(self.formals.declaredTypeBindings())
    # type the body in that extended type environment
    expType = self.exp.evalType(ntenv)
    # and check that the declared return type matches the body's
    declaredReturnType.checkEquals(expType)
    return ProcType(self.formals.formalTypeList(), declaredReturnType)
```

Type checking an `if` expression involves making sure that the controlling
expression has type `bool` and that the true part and the false part have the
same types. Thus, for a `IfExp`, we have:

```python
def evalType(self, tenv):
    testType = self.testExp.evalType(tenv)
    testType.checkBoolType(Type.boolType())
    trueExpType = self.trueExp.evalType(tenv)
    falseExpType = self.falseExp.evalType(tenv)
    trueExpType.checkEquals(falseExpType)
    return trueExpType
```

What is the type of a sequence expression? Since the purpose of this expression
is normally to perform side-effects and to return only the value of the last
sub-expression, we assume that the type of "`{ ... }`" is the type of the last
sub-expression. The types of the previous sub-expressions are ignored except
that they must not have type errors.

Thus the expression

```
let
  x = 1
  double = proc(t : int) : int set t = *(2, t)
in
  { if zero?(x) then 0 else set x = add1(x)
  ; .double(x)
  ; proc() : int x
  }
```

has type `[ => int ]`.

The following method implements type checking in the `SeqExp` class:

```python
def evalType(self, tenv):
    t = self.exp.evalType(tenv)
    for e in self.seqExps.expList:
        t = e.evalType(tenv)
    return t
```

In a `set` expression, we look up the type of the left-hand side variable and
make sure that it matches the type of the right-hand side expression. The
following method is defined in the `SetExp` class:

```python
def evalType(self, tenv):
    varType = tenv.applyTypeEnv(self.symbol.lexeme)
    expType = self.exp.evalType(tenv)
    varType.checkEquals(expType)
    return varType
```

A `letrec` expression is treated similarly to a `let` expression, except that
the types of the right-hand side functions must be evaluated in an environment
that has type bindings for the left-hand side variables. Since the defined type
of a right-hand side function can be determined solely by declared types of its
parameters and return type, the types of the left-hand side variables can be
determined independent of any environment. So we can use these left-hand side
variables to extend the type environment and then evaluate the types of the
right-hand side function *bodies* using this extended environment, for the
purpose of type checking with their declared return types. The
`addLetrecTypeBindings` method in the `LetDecls` class does all the work.

```python
def addLetrecTypeBindings(self, tenv):
    from ProcExp import ProcExp
    tenv = tenv.extendTypeEnv(TypeBindings())
    # a proc's type comes from its annotations alone,
    # so bind the procs first, before checking any body
    for sym, e in zip(self.symbolList, self.expList):
        if isinstance(e, ProcExp):
            tenv.add(TypeBinding(sym.lexeme, e.proc.definedType()))
    for sym, e in zip(self.symbolList, self.expList):
        typ = e.evalType(tenv)
        if not isinstance(e, ProcExp):
            tenv.add(TypeBinding(sym.lexeme, typ))
    return tenv
```

Once we have type checked the right-hand side entries and built the extended
type environment with bindings for the left-hand side variables, we can evaluate
the type of the `letrec` body using this extended environment.

```
LetrecExp
%%%
def evalType(self, tenv):
    ntenv = self.letDecls.addLetrecTypeBindings(tenv)
    return self.exp.evalType(ntenv)
%%%
```

At first glance, we might imagine that `addLetrecTypeBindings` should be able to
process all bindings in one pass. Unfortunately that hope is misplaced for
`letrec` declarations containing definitions of recursive functions (which was
the entire motivation for introducing the `letrec` construct in the first
place). In those cases, the type checker will fail with an error. Consider the
following example:

```
letrec
  fact = proc(n : int) : int if zero?(n) then 1 else *(n, .fact(sub1(n)))
in
  .fact(5)
```

With a naive implementation of `addLetrecTypeBindings`, its processing would
end with the error message `no type binding for fact`. The reason for this error
is that when analyzing the right-hand side of the declaration in environment
`tenv`, that environment does not yet include the type signature for `fact`.
Without that signature the checker cannot verify that the function's argument
and return value are of acceptable types.

We two more types of expressions to cover: `AppExp` and `PrimappExp`. Both of
them are similar in that we need to check if the formal parameter types of the
operator agree in number and type with the actual parameter (operand) types.

For an `AppExp`, we must ensure that the thing we are applying is actually a
function — it must evaluate to a `ProcType`. We then check that the actual
parameter expression types match the declared types of the formal parameters.
Because a `ProcType` object already knows (and has checked the validity of) its
return type, the type of an application is simply the return type of the
function:

```
AppExp
%%%
def evalType(self, tenv):
    pt = self.exp.evalType(tenv).procType()
    argTypeList = self.rands.evalTypeRands(tenv)
    Type.checkEqualTypes(pt.paramTypeList, argTypeList)
    return pt.returnType
%%%
```

For `PrimappExp`, we perform the same steps, except that we simply ask the
primitive to identify its type using its `definedType` method:

```
PrimappExp
%%%
def evalType(self, tenv):
    pt = self.prim.definedType()
    argTypeList = self.rands.evalTypeRands(tenv)
    Type.checkEqualTypes(pt.paramTypeList, argTypeList)
    return pt.returnType
%%%
```

Notice that the type of a primitive is defined statically. The primitive's
`definedType` method just retrieves the type, which must be a `ProcType`.

## Type-check defines

We are left to handle top-level `define`s. While their handling seems to be
straightforward, we are faced with problems of unbound variables. For example,
suppose we attempt to make the following definitions:

```
define odd? =
  proc(x : int) : bool if zero?(x) then false else .even?(sub1(x))
define even? =
  proc(x : int) : bool if zero?(x) then true else .odd?(sub1(x))
```

When the function body of `odd?` is first encountered, the variable `even?` is
unbound, so the type of the body of the function cannot be evaluated. Any
attempt to type-check `odd?` fails with a type error.

We can remedy this situation in two ways:

* forbid top-level `define`s altogether; or
* create a mechanism to deal with unbound variables that makes top-level
  `define`s work.

### Declarations

We choose the second approach, with some restrictions.

First, we create a new top-level operator `declare` that has a syntax similar to
how we declare the type of a formal parameter in a function. This technique
allows us to bind a type to an identifier without actually creating a value
binding for the identifier.

Pascal provides such a mechanism with `forward` declarations, as does C/C++ with
function declarations. Java does not suffer from this problem, in part because
the order of declaration of fields and methods is not significant.

A declaration has the following syntax:

```
<Program:Declare>       ::= DECLARE <SYMBOL> COLON <TypeExp>
```

The rules for top-level `define`s and `declare`s are:

1. A top-level identifier definition serves as a declaration for the purpose of
   determining the type of the identifier.

2. It is an error for a top-level identifier to be declared (hence defined) more
   than once.

3. If an identifier declaration precedes its definition, it is an error if the
   declared and defined types are not identical.

4. It is an error for a declaration not to have a subsequent definition,
   although this error need not be checked.

Although you cannot `define` a top-level variable more than once, you can
*redefine* a top-level variable using `set` if the variable has been previously
`define`d. The type rule for variable assignment still requires that the
right-hand side type of the `set` must agree with the declared type of the
variable.

Below are examples of top-level declarations/definitions:

```
% example 1
define x = 3 % type int
define x = 4 % error - multiple definitions for x
```

```
% example 2
define x = 3 % type int
set x = 4    % ok - types agree
set x = true % error - type of RHS must be int
```

```
% example 3
define fact = proc(x : int) : int
  if zero?(x) then 1 else *(x, .fact(sub1(x)))
  % error - fact on the RHS has no type binding!
```

```
% example 4
declare fact : [ int => int ]
define fact = proc(x : int) : int
  if zero?(x) then 1 else *(x, .fact(sub1(x))) % ok
```

```
% example 5
declare f : [ => bool ]
define y = 2
define f = proc() : int y
  % error - defined type of f does not match declared type
```

```
% example 6
declare f : [ => bool ]
define y = 2
define f = proc() : bool y
  % error - body type y does not match declared return type
```

As a final example, consider

```
declare f : [ => int ]
declare y : int
define f = proc() : int y
.f() % error - no binding for y
```

The definition for `f` is type valid, but `y` has no defined value binding, so
the function application `.f()` results in a run-time error.

If we subsequently give a value definition for `y`, the function application
succeeds, as the following shows:

```
declare f : [ => int ]
declare y : int
define f = proc() : int y
define y = 3
.f() % ok - returns 3
```

We implement top-level declarations as follows:

```
Declare
%%%
def _run(self):
    tenv = Program.tenv
    sym = self.symbol.lexeme
    try:
        tenv.applyTypeEnv(sym)
    except LanguageError:
        # no type binding -- a new type declaration, which we add
        # to the top-level type environment
        varType = self.typeExp.toType()
        tenv.add(TypeBinding(sym, varType))
        return f"{sym}:{varType}"
    raise LanguageError(f"{sym}: duplicate variable declaration")
%%%
```

If a type binding (either through a declaration of definition) already exists,
it is flagged as a duplicate declaration. Otherwise a top-level binding is made
between the identifier and the type represented by its type expression. The
`_run` behavior of a variable declaration/definition is to return the variable
being declared/defined along with its declared type.

We expand on top-level definitions as follows. Notice that this code is in two
parts: the first part is where the variable hasn't been declared/defined before
(i.e., the first `try` block) and the second part is where the variable has a
declaration but possibly not a definition (i.e., the second `try` block):

```
Define
%%%
def _run(self):
    env = Program.env
    tenv = Program.tenv
    sym = self.symbol.lexeme
    try:
        lhsVarType = tenv.applyTypeEnv(sym)
    except LanguageError:
        # no type binding -- a new variable definition
        rhsExpType = self.exp.evalType(tenv)
        tenv.add(TypeBinding(sym, rhsExpType))
        rhsExpVal = self.exp.eval(env)
        env.add(Binding(sym, ValRef(rhsExpVal)))
        return f"{sym}:{rhsExpType}"
    # the variable has a declared type -- see if it still needs a value
    try:
        env.applyEnv(sym)
    except LanguageError:
        rhsExpType = self.exp.evalType(tenv)
        # the declared and defined types must be the same
        lhsVarType.checkEquals(rhsExpType)
        rhsExpVal = self.exp.eval(env)
        env.add(Binding(sym, ValRef(rhsExpVal)))
        return f"{sym}:{rhsExpType}"
    # the variable has a value too -- can't redefine it
    raise LanguageError(f"{sym}: duplicate variable definition")
%%%
```

The code above implements a top-level definition, binding a value to an
identifier in the initial environment. According to our type rules, if a value
binding already exists, it is flagged as an error. If a declared type binding
exists without a value binding, the expression type is checked for conformance
with the declared type. If a declared type binding does not exist, the top-level
type environment is extended to include the type binding. In case there are no
errors, the top-level value environment is extended to include the value
binding.

Armed with both `declare` and `define`, we can now implement our `odd?` and
`even?` functions:

```
declare odd? : [ int => bool ]
define even? =
    proc(t : int) : bool if zero?(t) then true else .odd?(sub1(t))
define odd? =
    proc(t : int) : bool if zero?(t) then false else .even?(sub1(t))
```
