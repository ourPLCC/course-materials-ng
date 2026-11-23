## OBJ

### After `define C`

Each class's static environment extends its superclass's static environment, or
the initial environment if it has no superclass.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define A = class
  static x = 3
end
define B = class
  static y = 4
end
define C = class extends B
  static z = 5
end
]

map "empty:EnvNull" as empty_EnvNull {
}

map "init:EnvNode" as init_EnvNode {
}

map "init:Bindings" as init_Bindings {
  A => ...
  B => ...
  C => ...
}

package "A" {
  map "statics:EnvNode" as A_statics_EnvNode {
  }

  map "statics:Bindings" as A_statics_Bindings {
    x => 3
  }
}

package "B" {
  map "statics:EnvNode" as B_statics_EnvNode {
  }

  map "statics:Bindings" as B_statics_Bindings {
    y => 4
  }
}

package "C" {
  map "statics:EnvNode" as C_statics_EnvNode {
  }

  map "statics:Bindings" as C_statics_Bindings {
    z => 5
  }
}

empty_EnvNull <-- init_EnvNode
init_EnvNode <--- A_statics_EnvNode
A_statics_EnvNode -> A_statics_Bindings
init_EnvNode -> init_Bindings

init_EnvNode <--- B_statics_EnvNode
B_statics_EnvNode -> B_statics_Bindings

B_statics_EnvNode <-- C_statics_EnvNode
C_statics_EnvNode -> C_statics_Bindings

@enduml
```

### After `define a2`

Each object has its own chain of environments. Its statics environment shares
the class's static bindings, so both objects see the same `x`.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define A = class
  static x = 3
  field y
  method f = proc() 0
end
define a = new A
define a2 = new A
]

map "empty:EnvNull" as empty_EnvNull {
}

map "init:EnvNode" as init_EnvNode {
}

map "init:Bindings" as init_Bindings {
  A => ...
  a => ...
  a2 => ...
}

package "A" {
  map "statics:EnvNode" as A_statics_EnvNode {
  }

  map "statics:Bindings" as A_statics_Bindings {
    x => 3
  }
}

empty_EnvNull <-- init_EnvNode
init_EnvNode <-- A_statics_EnvNode

A_statics_EnvNode -> A_statics_Bindings
init_EnvNode -> init_Bindings

package "a" {

  package "a::Root" {
    map "root:EnvNode" as a_root_EnvNode {
    }

    map "root:Bindings" as a_root_Bindings {
    }

    a_root_EnvNode -> a_root_Bindings
  }

  package "a::A" {
    map "statics:EnvNode" as a_A_statics_EnvNode {
    }

    map "fields:EnvNode" as a_A_fields_EnvNode {
    }

    map "fields:Bindings" as a_A_fields_Bindings {
      y => nil
    }

    map "methods:EnvNode" as a_A_methods_EnvNode {
    }

    map "methods:Bindings" as a_A_methods_Bindings {
      f => ...
    }

    a_A_statics_EnvNode -> A_statics_Bindings
    a_A_fields_EnvNode -> a_A_fields_Bindings
    a_A_methods_EnvNode -> a_A_methods_Bindings
  }
}

init_EnvNode <-- a_root_EnvNode
a_root_EnvNode <-- a_A_statics_EnvNode
a_A_statics_EnvNode <-- a_A_fields_EnvNode
a_A_fields_EnvNode <-- a_A_methods_EnvNode

package "a2" {

  package "a2::Root" {
    map "root:EnvNode" as a2_root_EnvNode {
    }

    map "root:Bindings" as a2_root_Bindings {
    }

    a2_root_EnvNode -> a2_root_Bindings
  }

  package "a2::A" {
    map "statics:EnvNode" as a2_A_statics_EnvNode {
    }

    map "fields:EnvNode" as a2_A_fields_EnvNode {
    }

    map "fields:Bindings" as a2_A_fields_Bindings {
      y => nil
    }

    map "methods:EnvNode" as a2_A_methods_EnvNode {
    }

    map "methods:Bindings" as a2_A_methods_Bindings {
      f => ...
    }

    a2_A_statics_EnvNode -> A_statics_Bindings
    a2_A_fields_EnvNode -> a2_A_fields_Bindings
    a2_A_methods_EnvNode -> a2_A_methods_Bindings
  }
}

init_EnvNode <-- a2_root_EnvNode
a2_root_EnvNode <-- a2_A_statics_EnvNode
a2_A_statics_EnvNode <-- a2_A_fields_EnvNode
a2_A_fields_EnvNode <-- a2_A_methods_EnvNode

@enduml
```

### After `define b`

An object has one part for each class in its chain, plus the root. Each part's
statics environment shares its class's static bindings, so the object's chain
weaves together the statics, fields, and methods of `A` and `B`. The classes
have their own, separate chain.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define A = class
  static x = 3
  field y
  method f = proc() 0
end
define B = class extends A
  static u = 5
  field v
  method g = proc() 1
end
define b = new B
]

map "empty:EnvNull" as empty_EnvNull {
}

map "init:EnvNode" as init_EnvNode {
}

map "init:Bindings" as init_Bindings {
  A => ...
  B => ...
  b => ...
}

init_EnvNode -> init_Bindings

empty_EnvNull <-- init_EnvNode

package "A" {
  map "statics:EnvNode" as A_statics_EnvNode {
  }

  map "statics:Bindings" as A_statics_Bindings {
    x => 3
  }

  A_statics_EnvNode -> A_statics_Bindings
  init_EnvNode <-- A_statics_EnvNode
}

package "B" {
  map "statics:EnvNode" as B_statics_EnvNode {
  }

  map "statics:Bindings" as B_statics_Bindings {
    u => 5
  }

  B_statics_EnvNode -> B_statics_Bindings
  A_statics_EnvNode <-- B_statics_EnvNode
}

package "b" {

  package "b::Root" {
    map "root:EnvNode" as b_root_EnvNode {
    }

    map "root:Bindings" as b_root_Bindings {
    }

    b_root_EnvNode -> b_root_Bindings
    init_EnvNode <-- b_root_EnvNode
  }

  package "b::A" {
    map "statics:EnvNode" as b_A_statics_EnvNode {
    }

    b_A_statics_EnvNode -> A_statics_Bindings
    b_root_EnvNode <-- b_A_statics_EnvNode

    map "fields:EnvNode" as b_A_fields_EnvNode {
    }

    map "fields:Bindings" as b_A_fields_Bindings {
      y => nil
    }

    b_A_statics_EnvNode <-- b_A_fields_EnvNode
    b_A_fields_EnvNode -> b_A_fields_Bindings

    map "methods:EnvNode" as b_A_methods_EnvNode {
    }

    map "methods:Bindings" as b_A_methods_Bindings {
      f => ...
    }

    b_A_methods_EnvNode -> b_A_methods_Bindings
    b_A_fields_EnvNode <-- b_A_methods_EnvNode
  }

  package "b::B" {
    map "statics:EnvNode" as b_B_statics_EnvNode {
    }

    b_B_statics_EnvNode -> B_statics_Bindings
    b_A_methods_EnvNode <-- b_B_statics_EnvNode

    map "fields:EnvNode" as b_B_fields_EnvNode {
    }

    map "fields:Bindings" as b_B_fields_Bindings {
      v => nil
    }

    b_B_statics_EnvNode <-- b_B_fields_EnvNode
    b_B_fields_EnvNode -> b_B_fields_Bindings

    map "methods:EnvNode" as b_B_methods_EnvNode {
    }

    map "methods:Bindings" as b_B_methods_Bindings {
      g => ...
    }

    b_B_methods_EnvNode -> b_B_methods_Bindings
    b_B_fields_EnvNode <-- b_B_methods_EnvNode
  }
}

@enduml
```

### The `Val` classes for classes and objects

This is a class diagram of the interpreter, not an environment diagram. In OBJ,
classes and objects are values: a class is a `ClassVal`, and an object is made
of `ObjectVal`s. An `EnvClass` is the root of every class chain, and a
`StdClass` is made by a `class` expression.

```plantuml
@startuml
abstract class Val {
  env() { raise LanguageError() }
  makeObject(Ref) { raise LanguageError() }
}
class ObjectVal extends Val {
  objectEnv : Env
  env() -> Env { return objectEnv }
}
abstract class ClassVal extends Val {
  {abstract} makeObject(Ref) -> ObjectVal
}
class EnvClass extends ClassVal {
  staticEnv : Env
  env() -> Env { return staticEnv }
  makeObject(Ref) -> ObjectVal
}
class StdClass extends ClassVal {
  superClass : ClassVal
  staticBindings : Bindings
  staticEnv : Env
  fields : Fields
  methods : Methods
  env() -> Env { return staticEnv }
  makeObject(Ref) -> ObjectVal
}

@enduml
```

### After `define b`, with values

Classes and objects are values that point to environments. A `StdClass` points
to its class's statics environment, and each `ObjectVal` points to the bottom
environment of its part. The environments are the same as in "After `define b`".

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define A = class
  static x = 3
  field y
  method f = proc() 0
end
define B = class extends A
  static u = 5
  field v
  method g = proc() 1
end
define b = new B
]

map "empty:EnvNull" as empty_EnvNull {
}

map "init:EnvNode" as init_EnvNode {
}

map "init:Bindings" as init_Bindings {
  A => ...
  B => ...
  b => ...
}

init_EnvNode -> init_Bindings

empty_EnvNull <-- init_EnvNode

map ":EnvClass" as A_EnvClass {
  staticEnv *-> init_EnvNode
}

package "A" {
  map "statics:EnvNode" as A_statics_EnvNode {
  }

  map "statics:Bindings" as A_statics_Bindings {
    x => 3
  }

  A_statics_EnvNode -> A_statics_Bindings
  init_EnvNode <-- A_statics_EnvNode

  map "A:StdClass" as A_StdClass {
    superClass *-> A_EnvClass
    staticBindings *-> A_statics_Bindings
    staticEnv *-> A_statics_EnvNode
    fields => ...
    methods => ...
  }
}

package "B" {
  map "statics:EnvNode" as B_statics_EnvNode {
  }

  map "statics:Bindings" as B_statics_Bindings {
    u => 5
  }

  B_statics_EnvNode -> B_statics_Bindings
  A_statics_EnvNode <-- B_statics_EnvNode

  map "B:StdClass" as B_StdClass {
    superClass *-> A_StdClass
    staticBindings *-> B_statics_Bindings
    staticEnv *-> B_statics_EnvNode
    fields => ...
    methods => ...
  }
}

package "b" {

  package "b::Root" {
    map "root:EnvNode" as b_root_EnvNode {
    }

    map "root:Bindings" as b_root_Bindings {
    }

    b_root_EnvNode -> b_root_Bindings
    init_EnvNode <-- b_root_EnvNode

    map ":ObjectVal" as b_root_ObjectVal {
      objectEnv *-> b_root_EnvNode
    }
  }

  package "b::A" {
    map "statics:EnvNode" as b_A_statics_EnvNode {
    }

    b_A_statics_EnvNode -> A_statics_Bindings
    b_root_EnvNode <-- b_A_statics_EnvNode

    map "fields:EnvNode" as b_A_fields_EnvNode {
    }

    map "fields:Bindings" as b_A_fields_Bindings {
      y => nil
    }

    b_A_statics_EnvNode <-- b_A_fields_EnvNode
    b_A_fields_EnvNode -> b_A_fields_Bindings

    map "methods:EnvNode" as b_A_methods_EnvNode {
    }

    map "methods:Bindings" as b_A_methods_Bindings {
      f => ...
    }

    b_A_methods_EnvNode -> b_A_methods_Bindings
    b_A_fields_EnvNode <-- b_A_methods_EnvNode

    map ":ObjectVal" as b_A_ObjectVal {
      objectEnv *-> b_A_methods_EnvNode
    }
  }

  package "b::B" {
    map "statics:EnvNode" as b_B_statics_EnvNode {
    }

    b_B_statics_EnvNode -> B_statics_Bindings
    b_A_methods_EnvNode <-- b_B_statics_EnvNode

    map "fields:EnvNode" as b_B_fields_EnvNode {
    }

    map "fields:Bindings" as b_B_fields_Bindings {
      v => nil
    }

    b_B_statics_EnvNode <-- b_B_fields_EnvNode
    b_B_fields_EnvNode -> b_B_fields_Bindings

    map "methods:EnvNode" as b_B_methods_EnvNode {
    }

    map "methods:Bindings" as b_B_methods_Bindings {
      g => ...
    }

    b_B_methods_EnvNode -> b_B_methods_Bindings
    b_B_fields_EnvNode <-- b_B_methods_EnvNode

    map "b:ObjectVal" as b_B_ObjectVal {
      objectEnv *-> b_B_methods_EnvNode
    }
  }
}

@enduml
```

### After `define A`, with static `ProcVal`s

A class's statics are evaluated in order when its `class` expression is
evaluated. As in `letrec`, each `ProcVal` captures the environment it is being
added to, here the class's statics environment. So static functions can call
themselves and each other, and can use the statics of superclasses.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define A = class
    static f = proc() 1
    static g = proc() 2
end
]

map "empty:EnvNull" as empty_EnvNull {
}

map "init:EnvNode" as init_EnvNode {
}

map "init:Bindings" as init_Bindings {
  A => ...
}

init_EnvNode -> init_Bindings
empty_EnvNull <-- init_EnvNode

map "f:ProcVal" as f_ProcVal {
  formals =>
  body => 1
  env =>
}

map "g:ProcVal" as g_ProcVal {
  formals =>
  body => 2
  env =>
}

package "A" {
  map "statics:EnvNode" as A_statics_EnvNode {
  }

  map "statics:Bindings" as A_statics_Bindings {
    f *--> f_ProcVal
    g *--> g_ProcVal
  }

  A_statics_EnvNode -> A_statics_Bindings

  map "A:StdClass" as A_StdClass {
    superClass => ...
    staticBindings *-> A_statics_Bindings
    staticEnv *-> A_statics_EnvNode
    fields => ...
    methods => ...
  }
}

init_EnvNode <-- A_statics_EnvNode

A_statics_EnvNode <-- f_ProcVal::env
A_statics_EnvNode <-- g_ProcVal::env

@enduml
```

### After `define a`, with method `ProcVal`s

Each method's `ProcVal` captures the methods environment of its object's part.
So a method can use that part's methods, including itself, as well as its fields
and statics, and those of the parts above it. It cannot use the names in parts
below it directly.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define A = class
    method f = proc() 1
    method g = proc() 2
end
define a = new A
]

map "empty:EnvNull" as empty_EnvNull {
}

map "init:EnvNode" as init_EnvNode {
}

map "init:Bindings" as init_Bindings {
  A => ...
  a => ...
}

init_EnvNode -> init_Bindings
empty_EnvNull <-- init_EnvNode

package "A" {
  map "statics:EnvNode" as A_statics_EnvNode {
  }

  map "statics:Bindings" as A_statics_Bindings {
  }

  A_statics_EnvNode -> A_statics_Bindings
}

init_EnvNode <-- A_statics_EnvNode

package "a" {

  package "a::Root" {
    map "root:EnvNode" as a_root_EnvNode {
    }

    map "root:Bindings" as a_root_Bindings {
    }

    a_root_EnvNode -> a_root_Bindings
  }

  package "a::A" {
    map "f:ProcVal" as f_ProcVal {
      formals =>
      body => 1
      env =>
    }

    map "g:ProcVal" as g_ProcVal {
      formals =>
      body => 2
      env =>
    }

    map "statics:EnvNode" as a_A_statics_EnvNode {
    }

    a_A_statics_EnvNode -> A_statics_Bindings

    map "fields:EnvNode" as a_A_fields_EnvNode {
    }

    map "fields:Bindings" as a_A_fields_Bindings {
    }

    a_A_fields_EnvNode -> a_A_fields_Bindings

    map "methods:EnvNode" as a_A_methods_EnvNode {
    }

    map "methods:Bindings" as a_A_methods_Bindings {
      f *--> f_ProcVal
      g *--> g_ProcVal
    }

    a_A_methods_EnvNode -> a_A_methods_Bindings

    map "a:ObjectVal" as a_A_ObjectVal {
      objectEnv *-> a_A_methods_EnvNode
    }
  }
}

init_EnvNode <-- a_root_EnvNode
a_root_EnvNode <-- a_A_statics_EnvNode
a_A_statics_EnvNode <-- a_A_fields_EnvNode
a_A_fields_EnvNode <-- a_A_methods_EnvNode

a_A_methods_EnvNode <-[norank]- f_ProcVal::env
a_A_methods_EnvNode <-[norank]- g_ProcVal::env

@enduml
```

### After `define b`, with method `ProcVal`s

Each method's `ProcVal` captures the methods environment of its own part. So `g`
can use everything in both parts, but `f` can directly use only what is in
`b::A` and above, even though it is part of the same object as `g`.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define A = class
  static x = 3
  field y
  method f = proc() 0
end
define B = class extends A
  static u = 5
  field v
  method g = proc() 1
end
define b = new B
]

map "empty:EnvNull" as empty_EnvNull {
}

map "init:EnvNode" as init_EnvNode {
}

map "init:Bindings" as init_Bindings {
  A => ...
  B => ...
  b => ...
}

init_EnvNode -> init_Bindings

empty_EnvNull <-- init_EnvNode

package "A" {
  map "statics:EnvNode" as A_statics_EnvNode {
  }

  map "statics:Bindings" as A_statics_Bindings {
    x => 3
  }

  A_statics_EnvNode -> A_statics_Bindings
  init_EnvNode <-- A_statics_EnvNode
}

package "B" {
  map "statics:EnvNode" as B_statics_EnvNode {
  }

  map "statics:Bindings" as B_statics_Bindings {
    u => 5
  }

  B_statics_EnvNode -> B_statics_Bindings
  A_statics_EnvNode <-- B_statics_EnvNode
}

package "b" {

  package "b::Root" {
    map "root:EnvNode" as b_root_EnvNode {
    }

    map "root:Bindings" as b_root_Bindings {
    }

    b_root_EnvNode -> b_root_Bindings
    init_EnvNode <-- b_root_EnvNode
  }

  package "b::A" {
    map "statics:EnvNode" as b_A_statics_EnvNode {
    }

    b_A_statics_EnvNode -> A_statics_Bindings
    b_root_EnvNode <-- b_A_statics_EnvNode

    map "fields:EnvNode" as b_A_fields_EnvNode {
    }

    map "fields:Bindings" as b_A_fields_Bindings {
      y => nil
    }

    b_A_statics_EnvNode <-- b_A_fields_EnvNode
    b_A_fields_EnvNode -> b_A_fields_Bindings

    map "methods:EnvNode" as b_A_methods_EnvNode {
    }

    map "f:ProcVal" as f_ProcVal {
      formals =>
      body => 0
      env =>
    }

    map "methods:Bindings" as b_A_methods_Bindings {
      f *--> f_ProcVal
    }

    b_A_methods_EnvNode -> b_A_methods_Bindings
    b_A_fields_EnvNode <-- b_A_methods_EnvNode
  }

  package "b::B" {
    map "statics:EnvNode" as b_B_statics_EnvNode {
    }

    b_B_statics_EnvNode -> B_statics_Bindings
    b_A_methods_EnvNode <--- b_B_statics_EnvNode

    map "fields:EnvNode" as b_B_fields_EnvNode {
    }

    map "fields:Bindings" as b_B_fields_Bindings {
      v => nil
    }

    b_B_statics_EnvNode <-- b_B_fields_EnvNode
    b_B_fields_EnvNode -> b_B_fields_Bindings

    map "methods:EnvNode" as b_B_methods_EnvNode {
    }

    map "g:ProcVal" as g_ProcVal {
      formals =>
      body => 1
      env =>
    }

    map "methods:Bindings" as b_B_methods_Bindings {
      g *--> g_ProcVal
    }

    b_B_methods_EnvNode -> b_B_methods_Bindings
    b_B_fields_EnvNode <-- b_B_methods_EnvNode
  }
}

b_A_methods_EnvNode <-[norank]- f_ProcVal::env
b_B_methods_EnvNode <-[norank]- g_ProcVal::env

@enduml
```

### After `define c`, with predefined symbols

The predefined symbols let code reach names that are shadowed in its scope. In
each part of an object, the fields bind `this` to that part, `super` to the part
above, and `self` to the bottom part. The root binds only `self`. In each class,
the statics bind `myclass` to that class and `superclass` to the class above. A
part shares its class's static bindings, so its code sees the same `myclass` and
`superclass`. These classes declare no methods, so their parts have no methods
environments.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define A = class end
define B = class extends A end
define C = class extends B end
define c = new C
]

map "empty:EnvNull" as empty_EnvNull {
}

map "init:EnvNode" as init_EnvNode {
}

map "init:Bindings" as init_Bindings {
  A => ...
  B => ...
  C => ...
  c => ...
}

map ":EnvClass" as A_EnvClass {
  staticEnv =>
}

init_EnvNode <- A_EnvClass::staticEnv
init_EnvNode -> init_Bindings
empty_EnvNull <-- init_EnvNode

package "A" {
  map "A:StdClass" as A_StdClass {
    superClass =>
    staticBindings => ...
    staticEnv =>
    fields => ...
    methods => ...
  }

  map "statics:EnvNode" as A_statics_EnvNode {
  }

  map "statics:Bindings" as A_statics_Bindings {
    superclass *-> A_EnvClass
    myclass *-> A_StdClass
  }
}

package "B" {
  map "B:StdClass" as B_StdClass {
    superClass =>
    staticBindings => ...
    staticEnv =>
    fields => ...
    methods => ...
  }

  map "statics:EnvNode" as B_statics_EnvNode {
  }

  map "statics:Bindings" as B_statics_Bindings {
    superclass *-> A_StdClass
    myclass *-> B_StdClass
  }
}

package "C" {
  map "C:StdClass" as C_StdClass {
    superClass =>
    staticBindings => ...
    staticEnv =>
    fields => ...
    methods => ...
  }

  map "statics:EnvNode" as C_statics_EnvNode {
  }

  map "statics:Bindings" as C_statics_Bindings {
    superclass *-> B_StdClass
    myclass *-> C_StdClass
  }
}

init_EnvNode <--- A_statics_EnvNode
A_statics_EnvNode <--- B_statics_EnvNode
B_statics_EnvNode <--- C_statics_EnvNode
A_EnvClass <--- A_StdClass::superClass
A_StdClass <--- B_StdClass::superClass
B_StdClass <--- C_StdClass::superClass

A_statics_EnvNode <- A_StdClass::staticEnv
B_statics_EnvNode <- B_StdClass::staticEnv
C_statics_EnvNode <- C_StdClass::staticEnv

A_statics_Bindings <- A_statics_EnvNode
B_statics_Bindings <- B_statics_EnvNode
C_statics_Bindings <- C_statics_EnvNode

package "c" {

  package "c::Root" {
    map ":ObjectVal" as c_root_ObjectVal {
      objectEnv =>
    }

    map "root:EnvNode" as c_root_EnvNode {
    }

    c_root_EnvNode <- c_root_ObjectVal::objectEnv

    map "root:Bindings" as c_root_Bindings {
      self =>
    }
  }

  package "c::A" {
    map "statics:EnvNode" as c_A_statics_EnvNode {
    }

    map "fields:EnvNode" as c_A_fields_EnvNode {
    }

    map ":ObjectVal" as c_A_ObjectVal {
      objectEnv =>
    }

    map "fields:Bindings" as c_A_fields_Bindings {
      super =>
      this =>
      self =>
    }
  }

  package "c::B" {
    map "statics:EnvNode" as c_B_statics_EnvNode {
    }

    map "fields:EnvNode" as c_B_fields_EnvNode {
    }

    map ":ObjectVal" as c_B_ObjectVal {
      objectEnv =>
    }

    map "fields:Bindings" as c_B_fields_Bindings {
      super =>
      this =>
      self =>
    }
  }

  package "c::C" {
    map "statics:EnvNode" as c_C_statics_EnvNode {
    }

    map "fields:EnvNode" as c_C_fields_EnvNode {
    }

    map "c:ObjectVal" as c_C_ObjectVal {
      objectEnv =>
    }

    map "fields:Bindings" as c_C_fields_Bindings {
      super =>
      this =>
      self =>
    }
  }
}

c_A_statics_EnvNode -> A_statics_Bindings
c_B_statics_EnvNode -> B_statics_Bindings
c_C_statics_EnvNode -> C_statics_Bindings

init_EnvNode <-- c_root_EnvNode
c_root_EnvNode <-- c_A_statics_EnvNode
c_A_statics_EnvNode <-- c_A_fields_EnvNode
c_A_fields_EnvNode <- c_A_ObjectVal::objectEnv
c_A_fields_EnvNode <-- c_B_statics_EnvNode
c_B_statics_EnvNode <-- c_B_fields_EnvNode
c_B_fields_EnvNode <- c_B_ObjectVal::objectEnv
c_B_fields_EnvNode <-- c_C_statics_EnvNode
c_C_statics_EnvNode <-- c_C_fields_EnvNode
c_C_fields_EnvNode <- c_C_ObjectVal::objectEnv

c_root_EnvNode -> c_root_Bindings
c_A_fields_EnvNode -> c_A_fields_Bindings
c_B_fields_EnvNode -> c_B_fields_Bindings
c_C_fields_EnvNode -> c_C_fields_Bindings

c_root_Bindings::self -[norank]-> c_C_ObjectVal

c_A_fields_Bindings::super -[norank]-> c_root_ObjectVal
c_A_fields_Bindings::this -[norank]-> c_A_ObjectVal
c_A_fields_Bindings::self -[norank]-> c_C_ObjectVal

c_B_fields_Bindings::super -[norank]-> c_A_ObjectVal
c_B_fields_Bindings::this -[norank]-> c_B_ObjectVal
c_B_fields_Bindings::self -[norank]-> c_C_ObjectVal

c_C_fields_Bindings::super -[norank]-> c_B_ObjectVal
c_C_fields_Bindings::this -[norank]-> c_C_ObjectVal
c_C_fields_Bindings::self -[norank]-> c_C_ObjectVal

@enduml
```
