## SET

### Before `.p(x)`

The state before the call in the "Formal parameter" section. Pairs with "During
`.p(x)`" below.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 3
  p = proc(t) set t = add1(t)
in
  { .p(x) ; x }  % here
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "let:EnvNode" as let_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
  }

  map "let:Bindings" as let_Bindings {
    x =>
    p =>
  }
}

'References
together {
  map "x:ValRef" as x_ValRef {
    val =>
  }

  map "p:ValRef" as p_ValRef {
    val =>
  }
}

'Values
together {
  map ":IntVal" as 3_IntVal {
    val => 3
  }

  map "p:ProcVal" as p_ProcVal {
    formals => t
    body => set t = add1(t)
    env =>
  }
}

'Edges

source ..> let_EnvNode : here

let_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
let_EnvNode --> let_Bindings

let_Bindings::x --> x_ValRef
let_Bindings::p --> p_ValRef

x_ValRef::val --> 3_IntVal
p_ValRef::val --> p_ProcVal

init_EnvNode <-- p_ProcVal::env

@enduml
```

### During `.p(x)`

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 3
  p = proc(t) set t = add1(t)  % here
in
  { .p(x) ; x }
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "let:EnvNode" as let_EnvNode {
  }

  map "app:EnvNode" as app_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
  }

  map "let:Bindings" as let_Bindings {
    x =>
    p =>
  }

  map "app:Bindings" as app_Bindings {
    t =>
  }
}

'References
together {
  map "x:ValRef" as x_ValRef {
    val =>
  }

  map "p:ValRef" as p_ValRef {
    val =>
  }

  map "t:ValRef" as t_ValRef {
    val =>
  }
}

'Values
together {
  map ":IntVal" as 3_IntVal {
    val => 3
  }

  map "p:ProcVal" as p_ProcVal {
    formals => t
    body => set t = add1(t)
    env =>
  }
}

'Edges

source ..> app_EnvNode : here

app_EnvNode -> init_EnvNode
let_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
let_EnvNode --> let_Bindings
app_EnvNode --> app_Bindings

let_Bindings::x --> x_ValRef
let_Bindings::p --> p_ValRef
app_Bindings::t --> t_ValRef

x_ValRef::val --> 3_IntVal
p_ValRef::val --> p_ProcVal
t_ValRef::val --> 3_IntVal

init_EnvNode <-- p_ProcVal::env

@enduml
```

### After `set t = add1(t)`

`t:ValRef` now holds a new `IntVal`, while `x:ValRef` and its value are untouched. This
is why the program evaluates to `3`. The dotted arrow shows that `t` started with
the same value as `x`.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 3
  p = proc(t) set t = add1(t)  % here
in
  { .p(x) ; x }
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "let:EnvNode" as let_EnvNode {
  }

  map "app:EnvNode" as app_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
  }

  map "let:Bindings" as let_Bindings {
    x =>
    p =>
  }

  map "app:Bindings" as app_Bindings {
    t =>
  }
}

'References
together {
  map "x:ValRef" as x_ValRef {
    val =>
  }

  map "p:ValRef" as p_ValRef {
    val =>
  }

  map "t:ValRef" as t_ValRef {
    val =>
  }
}

'Values
together {
  map ":IntVal" as 3_IntVal {
    val => 3
  }

  map "p:ProcVal" as p_ProcVal {
    formals => t
    body => set t = add1(t)
    env =>
  }

  map ":IntVal" as 4_IntVal {
    val => 4
  }
}

'Edges

source ..> app_EnvNode : here

app_EnvNode -> init_EnvNode
let_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
let_EnvNode --> let_Bindings
app_EnvNode --> app_Bindings

let_Bindings::x --> x_ValRef
let_Bindings::p --> p_ValRef
app_Bindings::t --> t_ValRef

x_ValRef::val --> 3_IntVal
p_ValRef::val --> p_ProcVal
t_ValRef::val --> 4_IntVal
t_ValRef::val -[dotted]-> 3_IntVal

init_EnvNode <-- p_ProcVal::env

@enduml
```

### After `set x = add1(x)`

The chapter's opening program. The dotted arrow shows where `x` pointed before
the `set`, because the replacement is the point of this diagram.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 42
in
  { set x = add1(x) ; x }  % here
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "let:EnvNode" as let_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
  }

  map "let:Bindings" as let_Bindings {
    x =>
  }
}

'References
together {
  map "x:ValRef" as x_ValRef {
    val =>
  }
}

'Values
together {
  map ":IntVal" as 42_IntVal {
    val => 42
  }

  map ":IntVal" as 43_IntVal {
    val => 43
  }
}

'Edges

source ..> let_EnvNode : here

let_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
let_EnvNode --> let_Bindings

let_Bindings::x --> x_ValRef

x_ValRef::val --> 43_IntVal
x_ValRef::val -[dotted]-> 42_IntVal

@enduml
```

### After `define g`

The "Environment capture" program. `define` adds `g` to the initial environment,
and the closure keeps `let:EnvNode` alive. The objects form a cycle: `init:EnvNode` reaches
`g:ProcVal` through its bindings, and `g:ProcVal` reaches `init:EnvNode` through `let:EnvNode`.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define g = let
             count = 0
           in
             proc() set count = add1(count)
.g()  % here
.g()
.g()
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "let:EnvNode" as let_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
    g =>
  }

  map "let:Bindings" as let_Bindings {
    count =>
  }
}

'References
together {
  map "g:ValRef" as g_ValRef {
    val =>
  }

  map "count:ValRef" as count_ValRef {
    val =>
  }
}

'Values
together {
  map "g:ProcVal" as g_ProcVal {
    formals =>
    body => set count = add1(count)
    env =>
  }

  map ":IntVal" as 0_IntVal {
    val => 0
  }
}

'Edges

source ..> init_EnvNode : here

let_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
let_EnvNode --> let_Bindings

init_Bindings::g --> g_ValRef
let_Bindings::count --> count_ValRef

g_ValRef::val --> g_ProcVal
count_ValRef::val --> 0_IntVal

let_EnvNode <-- g_ProcVal::env

@enduml
```

### During the first `.g()`

The call extends `let:EnvNode` with empty bindings, because `g` has no formal
parameters.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define g = let
             count = 0
           in
             proc() set count = add1(count)  % here
.g()
.g()
.g()
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "let:EnvNode" as let_EnvNode {
  }

  map "app:EnvNode" as app_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
    g =>
  }

  map "let:Bindings" as let_Bindings {
    count =>
  }

  map "app:Bindings" as app_Bindings {
  }
}

'References
together {
  map "g:ValRef" as g_ValRef {
    val =>
  }

  map "count:ValRef" as count_ValRef {
    val =>
  }
}

'Values
together {
  map "g:ProcVal" as g_ProcVal {
    formals =>
    body => set count = add1(count)
    env =>
  }

  map ":IntVal" as 0_IntVal {
    val => 0
  }
}

'Edges

source ..> app_EnvNode : here

app_EnvNode -> let_EnvNode
let_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
let_EnvNode --> let_Bindings
app_EnvNode --> app_Bindings

init_Bindings::g --> g_ValRef
let_Bindings::count --> count_ValRef

g_ValRef::val --> g_ProcVal
count_ValRef::val --> 0_IntVal

let_EnvNode <-[norank]- g_ProcVal::env

@enduml
```

### After the second `.g()`

`count` has persisted between calls. Each call's environment is unreachable once
the call returns, so it is not drawn.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
define g = let
             count = 0
           in
             proc() set count = add1(count)
.g()
.g()
.g()  % here
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "let:EnvNode" as let_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
    g =>
  }

  map "let:Bindings" as let_Bindings {
    count =>
  }
}

'References
together {
  map "g:ValRef" as g_ValRef {
    val =>
  }

  map "count:ValRef" as count_ValRef {
    val =>
  }
}

'Values
together {
  map "g:ProcVal" as g_ProcVal {
    formals =>
    body => set count = add1(count)
    env =>
  }

  map ":IntVal" as 2_IntVal {
    val => 2
  }
}

'Edges

source ..> init_EnvNode : here

let_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
let_EnvNode --> let_Bindings

init_Bindings::g --> g_ValRef
let_Bindings::count --> count_ValRef

g_ValRef::val --> g_ProcVal
count_ValRef::val --> 2_IntVal

let_EnvNode <-- g_ProcVal::env

@enduml
```
