# Environment diagram style guide for `OBJ`

This guide is for authors drawing environment diagrams for Language `OBJ`. It
extends **style-guide.md** in this directory and covers only what differs. Where
this guide says nothing, follow that one.

**diagrams-obj.md** holds the worked examples. We refer to them by their
headings, such as "After `define b`".

`OBJ` diagrams are larger than the others, and their layout carries meaning: it
shows how classes are related, what an object is made of, and how scoping works
through both. The layout matters more than following every default below.

## Reading an example

"After `define b`" shows class `A`, class `B` that extends it, and an object `b`
made from `B`:

* Chains run upward. `init:EnvNode` is near the top, and each environment points
  up to the one it extends.
* Each environment's bindings are to its right.
* The classes are on the right. Package `B` is below package `A`, and its
  statics environment extends `A`'s.
* The object is on the left. Package `b` holds its *parts*: `b::Root`, then
  `b::A`, then `b::B`.
* Each part's statics environment is its own, but points to the bindings in its
  class's package. So the same static bindings appear in the class's chain and,
  separately, in the object's chain.

## What a diagram shows

`OBJ` is based on `SET`, so references exist, but diagrams leave them out and
show values inline, such as `x => 3` and `y => nil`. `OBJ` passes parameters by
value only, so no diagram needs to show two variables sharing a reference.

`...` stands for a value whose box or arrow is not drawn.

### What the code creates

Check these against the [Python implementation][obj], because they are easy to
get wrong:

| Situation | What to draw |
|---|---|
| `class` | A statics environment with new bindings, extending the superclass's statics environment |
| `class` without `extends` | The same, extending the initial environment. Its superclass is a new `EnvClass`, so two such classes do not share one |
| `static` | A binding in the class's statics, evaluated in order in the statics environment |
| `new` | A root part, then one part for each class in the chain, from the top down |
| The root part | One environment extending the initial environment |
| Any other part | A statics environment extending the part above, then a fields environment, then a methods environment |
| A part's statics environment | A new `EnvNode` that shares the class's `Bindings` |
| A part's fields | Each bound to `nil` |
| A class that declares no methods | No methods environment in its part |
| A static `proc` | A `ProcVal` whose `env` points to the class's statics environment |
| A method | A new `ProcVal` for each object, whose `env` points to that part's methods environment |
| An object bound to a variable | The bottom part's `ObjectVal` |

An `ObjectVal`'s `objectEnv` points to the bottom environment of its part. That
is the methods environment, or the fields environment if there are no methods.

### What to leave out

* **Predefined symbols.** Leave `myclass` and `superclass` out of a class's
  static bindings, `self` out of a root's bindings, and `super`, `this`, and
  `self` out of a part's fields bindings. This can leave an empty box, such as
  `root:Bindings`. If the diagram is about them, show all of them, as in "After
  `define c`, with predefined symbols". Never show `!@`.
* **Classes and objects.** Leave out `StdClass` and `ObjectVal` boxes by
  default. Draw the ones that the diagram's point involves, and only those. Draw
  either every part's `ObjectVal` or only the bottom one.
* **`EnvClass`.** Draw `:EnvClass` only if the diagram shows superclasses.
  Otherwise, write `superClass => ...`.

Draw a class's package even if its `statics:Bindings` box is empty, so that the
statics environments in its objects have something to point to.

The rows of `init:Bindings` stay `...` even when the class and object boxes are
drawn. The matching names make the connection: `b` is bound to `b:ObjectVal`.

State these simplifications for readers once, where the first `OBJ` diagram
appears in the textbook. The paragraph above each diagram says what that diagram
shows.

## Declaring the diagram

Declare things in this order, with no groups and no `together`:

1. `skinparam fileFontName monospaced` and `file source [ ... ]`
2. `empty_EnvNull`, `init_EnvNode`, and `init_Bindings`
3. A package for each class, superclasses first
4. A package for each object, with its parts from the top down

Arrows can go beside the boxes they connect or at the end. Declare a box before
any `*->` or `*-->` row that points to it, as the examples do. We have not
tested whether PlantUML requires it. This means that `ProcVal`s come before the
bindings that hold them.

## Using packages

* A class's package holds its statics environment, its static bindings, and its
  `StdClass` if it is drawn.
* An object's package holds one nested package for each part, such as `b::Root`,
  `b::A`, and `b::B`, even if there is no inheritance.
* A part's package holds its environments, in the order statics, fields,
  methods, with their bindings beside them, and its `ObjectVal` if it is drawn.
* The initial environment and `:EnvClass` are not in a package.

## Naming boxes

The package says which class, object, or part a box belongs to, so its label
does not. The alias carries the full name.

| Object | Label | Alias |
|---|---|---|
| Class's statics environment | `statics:EnvNode` | `A_statics_EnvNode` |
| Class's static bindings | `statics:Bindings` | `A_statics_Bindings` |
| Root part's environment | `root:EnvNode` | `b_root_EnvNode` |
| Root part's bindings | `root:Bindings` | `b_root_Bindings` |
| Part's statics environment | `statics:EnvNode` | `b_A_statics_EnvNode` |
| Part's fields environment | `fields:EnvNode` | `b_A_fields_EnvNode` |
| Part's fields bindings | `fields:Bindings` | `b_A_fields_Bindings` |
| Part's methods environment | `methods:EnvNode` | `b_A_methods_EnvNode` |
| Part's methods bindings | `methods:Bindings` | `b_A_methods_Bindings` |
| Class | `A:StdClass` | `A_StdClass` |
| Superclass of a class without `extends` | `:EnvClass` | `A_EnvClass` |
| Bottom part of an object | `b:ObjectVal` | `b_B_ObjectVal` |
| Any other part of an object | `:ObjectVal` | `b_A_ObjectVal` |

A part has no static bindings box, because its statics environment points to the
one in the class's package.

Some boxes have specific rows:

* `StdClass` has `superClass`, `staticBindings`, `staticEnv`, `fields`, and
  `methods` rows. In a crowded diagram, a row may hold `...` in place of an
  arrow.
* `ObjectVal` has an `objectEnv` row, and `EnvClass` a `staticEnv` row.
* `ProcVal` has the usual `formals`, `body`, and `env` rows. Python names the
  attribute `procEnv`, to avoid a clash with `Val`'s `env` method, but diagrams
  keep `env`.

## Titling a diagram

Name the moment by its last `define`, such as "After `define b`". Add a
qualifier when two headings would be the same or differ only by case, such as
"After `define b`, with values".

## Showing where evaluation is

All the examples show the state after the program has run, so they have no
`% here` marker and no `here` arrow. We have no worked example of a diagram
during a call. To draw one, start from **style-guide.md**.

Without that arrow, PlantUML chooses where the source box goes. In the examples
it landed on the right, which saves height. To move it above the chain, add
`source -[hidden]-> empty_EnvNull`. We have not tested this.

## Drawing arrows

Chains run upward, so these replace the arrow forms in **style-guide.md**:

| Edge | Form | Example |
|---|---|---|
| Environment chain | `<--`, with the target on the left | `init_EnvNode <-- A_statics_EnvNode` |
| Environment to its bindings | `->` | `A_statics_EnvNode -> A_statics_Bindings` |
| Part's statics environment to the class's bindings | `->` | `b_A_statics_EnvNode -> A_statics_Bindings` |
| Row to a box | `*->` inside the row | `staticEnv *-> A_statics_EnvNode` |
| Row to a box that belongs below | `*-->` inside the row | `f *--> f_ProcVal` |
| `ProcVal`'s `env` row | `<--`, with the target on the left | `A_statics_EnvNode <-- f_ProcVal::env` |

## Fixing the layout

Change one thing at a time, and keep the last version that worked. When we made
several changes at once, we could not tell which one broke the layout.

| Problem | What to try |
|---|---|
| A chain arrow crosses a package's tab | Lengthen it to `<---`, and its siblings too, so that the packages stay level. It fixed "After `define C`" |
| A `ProcVal`'s `env` arrow puts a row out of order | `a_A_methods_EnvNode <-[norank]- f_ProcVal::env`. It fixed "After `define a`, with method `ProcVal`s" |
| `*->` rows put boxes in the wrong place | Switch those rows to separate arrows, as below |

To switch a row, leave it empty and add a separate arrow. Try these in turn:

1. An arrow in the direction of the chain, with the target on the left, such as
   `A_EnvClass <--- A_StdClass::superClass`.
2. An arrow with `norank`, such as
   `c_A_fields_Bindings::super -[norank]-> c_root_ObjectVal`.

Pointers between the parts of an object are the likeliest to need `norank`. In
"After `define c`, with predefined symbols", `*->` put the parts side by side.

Changing the order of declarations had no effect when we tried it. A hidden
arrow such as `g_ProcVal -[hidden]> f_ProcVal` reordered two boxes once, and had
no effect another time.

We accepted some flaws, such as arrows that overlap at one end or cross once,
when every arrow could still be followed. In "After `define b`, with method
`ProcVal`s", one bindings box is to the left of its environment, and changing
the `env` arrow did not move it.

## Drawing class diagrams

"The `Val` classes for classes and objects" is a class diagram of the
interpreter, so the rules above do not apply. Its title names its topic, and the
paragraph above it says that it is a class diagram. It uses the notation of the
class diagrams in the textbook's chapter on environments, with three
differences: it also writes `{ return ... }`, it marks abstract methods with
`{abstract}`, and it leaves out `__init__`.

[obj]: https://github.com/ourPLCC/languages-ng/blob/v1.0.0/src/OBJ/python/spec.plcc
