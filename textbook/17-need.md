# Language NEED

The call-by-need parameter passing mechanism is the same as call-by-name, except
that a thunk is called at most once, and its value is remembered (*memoized*).

## A quick tour

Suppose a function with formal parameter `x` is invoked with actual parameter
`set z = add1(z)`, using call-by-need semantics. As with call-by-name, the
formal parameter `x` is bound to the thunk with `set z = add1(z)` as its body,
in an enclosing environment that we will assume has `z` bound to (a reference
to) the value `8`. When `x` is referenced in the body of calling function, its
corresponding thunk is dereferenced, producing a result of `9` for `set z =
add1(z)`. The thunk now remembers (*memoizes*) the value `9`, and any further
references to the formal parameter `x` in the body of the function will
continue to evaluate to `9` without making any further changes to the variable
`z`.

If call-by-name had been used in the above example, additional evaluations of
`x` in the body of the function would result in evaluating the body of the
thunk for each such evaluation, further modifying `z` and yielding values `10`,
`11`, `12`, and so forth.

In both call-by-need and call-by-name (and unlike call-by-reference), if the
formal parameter is never referenced in the body of the function, the thunk is
never evaluated. Compared to call-by-name, call-by-need reduces the
*inefficiencies* of repeatedly evaluating a thunk when evaluating the
corresponding formal parameter.

## Implementation

Implementing call-by-need is easy, starting from the call-by-name interpreter.
The principal change is to have a `Val` attribute named `val` in the `ThunkRef`
class that is used to memoize the value of the body of the thunk. This attribute is
initialized to `None` when the thunk is created. When the thunk's `deRef` method
is invoked, it checks to see if the `val` attribute has been memoized (i.e., is
not `None`). If so, the `deRef` method simply returns the memoized value.
Otherwise, it evaluates the body of the thunk, saves the value in the `val`
attribute (thereby memoizing it), and then returns that value; subsequent `deRef`
calls simply use the resulting memoized value.

*In the NEED language, the `ThunkRef` initializer initializes the `val`
attribute to `None`, indicating that the thunk has not been memoized yet.
This attribute is modified when the thunk's `deRef` method is first called.*

The code excerpt summarizes the appropriate changes to `ThunkRef`

```
ThunkRef
%%%
class ThunkRef(Ref):

    def __init__(self, exp, env):
        self.exp = exp
        self.env = env
        self.val = None

    def deRef(self):
        if self.val is None:
            self.val = self.exp.eval(self.env)
        return self.val
```

## Read only

Reading the semantic specification of the `NEED` language, you might have
noticed that an instance of the class `ValRORef` is constructed by the `evalRef`
methods in the `LitExp` and `ProcExp` classes. This is a slight change from the
`NAME` language, where the instances were `ValRef`s. The `RO` part stands for
"read only". We do this because it doesn't make sense for a literal or function
to be modified.

Consider, for example, the following code:

```
let
  f = proc(x) set x = add1(x)
in
  .f(3)
```

One's intuition would be to think of the function application `.f(3)` as saying:

```
set 3 = add1(3)
```

But of course this doesn't make any sense.

We have already seen that the `setRef` method in the `ThunkRef` class raises an
exception. What we are now doing is to have this same behavior for *any* actual
parameter expression except for a variable (where call-by-reference is the
default).

## Difference between call-by-name and call-by-need

The following example illustrates the difference between call-by-name and
call-by-need:

```
let
  x = 3
  p = proc(t) {t ; t ; t}
in
  .p(set x = add1(x))
```

With call-by-name, when we apply the function `p`, its formal parameter `t` is
bound to a thunk containing the expression `set x = add1(x)`. Each time we
evaluate the formal parameter `t` in the body of the function `p`, its thunk is
dereferenced, resulting in evaluation of the expression `set x = add1(x)`. So
since we evaluate `t` three times in the body of `p`, the expression `set x =
add1(x)` gets evaluated three times, incrementing `x` from `3` to `6`.
Consequently, the entire expression evaluates to `6`.

With call-by-need, the first time we evaluate `t` in the body of `p`, its
corresponding actual parameter expression `set x = add1(x)` is evaluated, which
has the side-effect of incrementing the value of `x` to `4` and evaluates to
`4`. However, the thunk memoizes the expressed value of `4`, so any further
references we make to `t` evaluate to `4`. Consequently, the entire expression
evaluates to `4`.

Here's another example illustrating the difference between call-by-reference and
call-by-name/need. Examine the definition of `seq` which seems to recurse
infinitely but doesn't with call-by-name.

```
define pair = proc(x, y) proc(t) if t then y else x
define first = proc(p) .p(0)
define rest = proc(p) .p(1)
define nth = proc(n, lst)    % zero-based
  if n then .nth(sub1(n), .rest(lst)) else .first(lst)
define seq = proc(n) .pair(n, .seq(add1(n)))
define natno = .seq(0)       % all the natural numbers!!
```

The above never terminates with call-by-reference. With call-by-name or
call-by-need, a call to `.first(natno)` returns `0`, a call to
`.first(.rest(natno))` returns `1`, `.first(.rest(.rest(natno)))` returns `2`,
and so forth. A call `.nth(100, natno)` returns `100`.

## Order of evaluation

Let's examine the following example in Language `SET` (or `REF`):

```
let
  x = 3
in
  let
    y = {set x = add1(x)}
    z = {set x = add1(x)}
  in
    z
```

Consider the inner `let`. We know that the right-hand side expressions (here
written inside curly braces for clarity) are evaluated before their values are
bound to the left-hand variables. But our languages do not specify the order in
which the right-hand side expressions are evaluated.

In the absence of side-effects, that is, in our earlier languages without `set`
the order of evaluation of the right-hand side expressions would not matter.
However, when side-effects are possible, as in our interpreters such as `SET`
and `REF`, the order of evaluation does matter.

In the above example, if the second `set` is evaluated first, then `z` becomes
`4` and `y` becomes `5`, so the entire expression evaluates to `4` - the value
of `z`. If the order of evaluation is reversed, the entire expression evaluates
to `5`. Our languages do not specify order of evaluation; consequently, the
value of this expression is *ambiguous*.

A similar situation exists when evaluating actual parameter expressions,
as shown by this example, assuming call-by-value semantics.

```
let
  x = 3
  p = proc(t, u) t
in
  .p(set x = add1(x), set x = add1(x))
```

When the actual parameters are evaluated left-to-right as specified in our
languages, `t` would be bound to `4` and `u` to `5`, so the entire expression
evaluates to `4`. If the evaluation order had been right-to-left, the entire
expression would evaluate to `5`.

You can see that both `evalRands` and `evalRandsRef` use `foreach` loops to
traverse and evaluate the expressions in the list of actual parameters.
The traversal is guaranteed by the Python language specification to be
"natural", in the sense that the elements of the list are visited in ascending
item number order. Here is the code for `evalRands` in the `Rands` class:

```python
def evalRands(self, env):
    return [e.eval(env) for e in self.expList]
```

We are, of course, not under any obligation to use Python's `foreach` order of
evaluation mechanism to implement our `evalRands` semantics. We could, instead,
explicitly traverse the `expList` from last to first if we wished.

The point is that, to make any language semantics well-defined and unambiguous,
it is necessary to specify the order of evaluation. Unless the language
specification clearly addresses the issue of order of evaluation, the language
implementor can choose any evaluation order. *Let the buyer beware*.

The C language specification, for example, explicitly states that the order in
which actual parameter expressions are evaluated in *undefined*. If the order
of evaluation matters and is not specified, it is up to the programmer to avoid
actual parameter expressions that have side-effects. For example, none of our
languages specifies the order of evaluation of expressions. To ensure that the
previous program evaluates to `4`, it could be re-written as follows:

```
let
  x = 3
  p = proc(t, u) t
in
  let
    a = {set x = add1(x)}
  in
    let
      b = {set x = add1(x)}
    in
      .p(a, b)
```

Order of evaluation does not matter in languages with side-effects, which makes
functional languages immune to order of evaluation issues.

## Currying

Another way to avoid order of evaluation problems is to require that all
functions have at most one formal parameter. In languages that use this
approach, coupled with with call-by-need, there is never an "order of
evaluation" issue because there is never more than one actual parameter to
evaluate.

While you may think that a language with functions having only one formal
parameter might be limited, it's possible for such a language to behave like
having multiple formal parameters using an approach called "currying", as
employed in the Haskell programming language -- named after Haskell Curry.

Consider this initial example where `p` has two formal arguments:

```
let
  x = 3
  y = 5
  p = proc(t, u) +(t, u)
in
  .p(x, y)
```

This program evaluates to `8`. Below is the semantically equivalent code that
has exactly one formal parameter per `proc`:

```
let
  x = 3
  y = 5
  p = proc(t) proc(u) +(t, u)
in
  ..p(x)(y)
```

In the second example above, `x` must be evaluated first, so that the function
`.p(x)` can then be applied to the value of `y`.

## Aliasing

Side-effecting languages that use call-by-reference suffer from another danger.
Consider, for example, the following program using the `REF` language semantics:

```
let
  addplus1 = proc(x, y) {set x = add1(x) ; +(x, y)}
in
  .addplus1(3, 3)
```

It's clear that this program returns `7`. But what about the following program?

```
let
  a = 3
  addplus1 = proc(x, y) {set x = add1(x) ; +(x, y)}
in
  .addplus1(a, a)
```

Using call-by-reference, when `addplus1` is applied to the actual parameters `a`
and `a`, both formal parameters `x` and `y` of `addplus1` refer to the *same
cell* as `a`. Therefore the `set x = add1(x)` expression is equivalent to the
expression `set a = add1(a)` which increments `a` to `4`, and the next
expression `+(x, y)` is essentially equivalent to the expression `+(a, a)` which
now evaluates to `8`. Thus the value of the program is `8`.

*Aliasing* occurs when two different formal parameters refer to the same actual
parameter. As this example shows, aliasing can lead to unexpected side-effects
and should be avoided. **Of course, the best way to avoid problems such as
order of evaluation ambiguities and aliasing is to avoid using languages with
side-effects!**

## References

* "Aliasing (computing)," Wikipedia, last modified February 24, 2026
  [https://en.wikipedia.org/wiki/Aliasing_(computing)](https://en.wikipedia.org/wiki/Aliasing_(computing))

* "Currying," Wikipedia, last modified October 5, 2026
  [https://en.wikipedia.org/wiki/Currying](https://en.wikipedia.org/wiki/Currying)

* "Evaluation strategy," Wikipedia, last modified November 23, 2026
  [https://en.wikipedia.org/wiki/Evaluation_strategy](https://en.wikipedia.org/wiki/Evaluation_strategy)

## Going beyond

As stated earlier, the C language specification does not prescribe the order in
which actual parameter expressions are evaluated. This lack of specification has
led the GNU C and the Clang compilers to use a different evaluation order.
Therefore, the same program may output different results depending on the
compiler being used.

In contrast, the Java language specification is clear about order of
evaluation: actual parameter expressions are guaranteed to be evaluated
left-to-right (or "natural") order.
