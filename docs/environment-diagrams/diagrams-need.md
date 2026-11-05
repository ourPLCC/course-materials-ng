## NEED

New examples. The first two use the program from "Difference between call-by-name
and call-by-need" and show one thunk before and after memoizing.

### During `.p(set x = add1(x))`, before the first `t`

The thunk has not been evaluated, so its `val` is `None` and `x` is still `3`.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 3
  p = proc(t) {t ; t ; t}  % here
in
  .p(set x = add1(x))
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

  map "t:ThunkRef" as t_ThunkRef {
    exp => set x = add1(x)
    env =>
    val => None
  }
}

'Values
together {
  map ":IntVal" as 3_IntVal {
    val => 3
  }

  map "p:ProcVal" as p_ProcVal {
    formals => t
    body => {t ; t ; t}
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
app_Bindings::t --> t_ThunkRef

x_ValRef::val --> 3_IntVal
p_ValRef::val --> p_ProcVal

let_EnvNode <-- t_ThunkRef::env
init_EnvNode <-- p_ProcVal::env

@enduml
```

### During `.p(set x = add1(x))`, after the first `t`

Evaluating the thunk ran the `set`. `x:ValRef` and the thunk's `val` now point to the
same new `IntVal`, and the `IntVal` holding `3` is no longer reachable. Later
uses of `t` return the memoized value without running the `set` again.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 3
  p = proc(t) {t ; t ; t}  % here
in
  .p(set x = add1(x))
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

  map "t:ThunkRef" as t_ThunkRef {
    exp => set x = add1(x)
    env =>
    val =>
  }
}

'Values
together {
  map ":IntVal" as 4_IntVal {
    val => 4
  }

  map "p:ProcVal" as p_ProcVal {
    formals => t
    body => {t ; t ; t}
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
app_Bindings::t --> t_ThunkRef

x_ValRef::val --> 4_IntVal
p_ValRef::val --> p_ProcVal
t_ThunkRef::val --> 4_IntVal

let_EnvNode <-- t_ThunkRef::env
init_EnvNode <-- p_ProcVal::env

@enduml
```

### During `.f(3)`

The "Read only" program. A literal actual parameter is wrapped in a `ValRORef`, so
the `set` in the body raises an error.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  f = proc(x) set x = add1(x)  % here
in
  .f(3)
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
    f =>
  }

  map "app:Bindings" as app_Bindings {
    x =>
  }
}

'References
together {
  map "f:ValRef" as f_ValRef {
    val =>
  }

  map "x:ValRORef" as x_ValRORef {
    val =>
  }
}

'Values
together {
  map "f:ProcVal" as f_ProcVal {
    formals => x
    body => set x = add1(x)
    env =>
  }

  map ":IntVal" as 3_IntVal {
    val => 3
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

let_Bindings::f --> f_ValRef
app_Bindings::x --> x_ValRORef

f_ValRef::val --> f_ProcVal
x_ValRORef::val --> 3_IntVal

init_EnvNode <-- f_ProcVal::env

@enduml
```
