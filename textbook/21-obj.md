# Language OBJ

`OBJ` is an object-oriented programming language. The following program
is a partial implementation of a type supporting complex numbers.

```
define complex =
  class
    field r
    field i
    method init = proc(r_init, i_init) { set r = r_init ; set i = i_init ; self }
    method cadd = proc(o) { .<new complex>init(+(r, <o>r), +(i, <o>i)) }
    method get_real = proc() { r }
    method get_imag = proc() { i }
  end

let
  c1 = .<new complex>init(1, 0)
  c2 = .<new complex>init(1, 3)
in
  .<.<c1>cadd(c2)>get_real()
```

The body of the `let` expression chains methods `cadd` and `get_real` to
produce the real part of the sum of two complex numbers. The declaration part
of the `let` expression initializes the two complex numbers with values $1 + i$
and $1 + 3i$, respectively. The entire program evaluates to `2`.

## Classes and objects

Compared to most object-oriented programming languages such as Java and C++, our
classes and objects are *first class* — that is, they are values that can be
created at any time and in any environment, they can be bound to variables,
they can be passed as arguments to functions, and they can be returned as values
of function applications.

A *class* is an expressed value that captures a collection of variables
(*fields* or *attributes*) and function definitions (*methods*), and that serves as a
template to create expressed values called *instances* of the class.

The instances are called *objects*, to distinguish them from classes. You can
think of a class as a factory that identifies how to churn out an arbitrary
number of instances (objects) of the class.

## A simple example

Consider the class definition below.

```
define c =
  class
    field x
    field y
  end
```

It defines a new class with two fields named `x` and `y`. The definition is then
bound to the name `c`.

We can create a new instance of this class with the `new` keyword:

```
define o = new c
```

The expressions `<o>x` and `<o>y` evaluate to the values bound to `x` and `y`,
respectively, in object `o`. In languages such Python, C++, and Java, such
expressions would be written instead as `o.x` and `o.y`.

In Language `OBJ`, `<o>` denotes the environment, that is, bindings, associated
with instance `o`.
Then, any expression following that notation will be evaluated in that
environment. For instance, to mutate field `x` in `o`, we can write:

```
<o>set x = 3
```

## Class hierarchy

All classes of an `OBJ` program belong to a *class hierarchy*, which is
structured as a tree with an unnamed class at its root and with program-created
classes at all the other nodes.

In the class hierarchy, a class `X` that occurs as a child node of class `Y` in
the class hierarchy is called a *subclass* of `Y`, and `Y` is called a
*superclass* of `X`. In this case, we also say that `X` *extends* `Y`.

When an object of class `X` is instantiated, instances of each of the classes
that lie on the path from `X` to the root of the tree are created, and the
combination of all those instances is considered as the resulting object.

If `Y` is the superclass of `X`, then an object `x` created from class `X`
"contains" an object `y` created from `Y`. The object `y` is called the *parent*
of `x`, and likewise `x` is called the *child* of `y`.

Consider the following example:

```
define c1 =
  class
    field x
    field y
  end

define c2 =
  class extends c1
    field z
  end

define o2 = new c2

<<o2>super>set x = 3
<o2>x
```

In this example, `c1` extends the unnamed top-level class and `c2` is a subclass
of `c1`. Object `o2` is an instance of `c2` and `<o2>super` corresponds to the
instance of `c1` that is part of `o2`.
