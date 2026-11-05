## NAME

### Before `.f(5, x, proc(w) +(x, w), add1(x))`

The state just before the call in the "Illustrations" section. Pairs with "During
`.f(5, x, proc(w) +(x, w), add1(x))`" below.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 3
  f = proc(p, q, r, s) ...
in
  .f(5, x, proc(w) +(x, w), add1(x))  % here
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
    f =>
  }
}

'References
together {
  map "x:ValRef" as x_ValRef {
    val =>
  }

  map "f:ValRef" as f_ValRef {
    val =>
  }
}

'Values
together {
  map ":IntVal" as 3_IntVal {
    val => 3
  }

  map "f:ProcVal" as f_ProcVal {
    formals => p, q, r, s
    body => ...
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
let_Bindings::f --> f_ValRef

x_ValRef::val --> 3_IntVal
f_ValRef::val --> f_ProcVal

init_EnvNode <-- f_ProcVal::env

@enduml
```

### During `.f(5, x, proc(w) +(x, w), add1(x))`

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 3
  f = proc(p, q, r, s) ...  % here
in
  .f(5, x, proc(w) +(x, w), add1(x))
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
    f =>
  }

  map "app:Bindings" as app_Bindings {
    p =>
    q =>
    r =>
    s =>
  }
}

'References
together {
  map "x:ValRef" as x_ValRef {
    val =>
  }

  map "f:ValRef" as f_ValRef {
    val =>
  }

  map "p:ValRef" as p_ValRef {
    val =>
  }

  map "r:ValRef" as r_ValRef {
    val =>
  }

  map "s:ThunkRef" as s_ThunkRef {
    exp => add1(x)
    env =>
  }
}

'Values
together {
  map ":IntVal" as 3_IntVal {
    val => 3
  }

  map ":IntVal" as 5_IntVal {
    val => 5
  }

  map "f:ProcVal" as f_ProcVal {
    formals => p, q, r, s
    body => ...
    env =>
  }

  map "addX:ProcVal" as addX_ProcVal {
    formals => w
    body => +(x, w)
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
let_Bindings::f --> f_ValRef
app_Bindings::p --> p_ValRef
app_Bindings::q --> x_ValRef
app_Bindings::r --> r_ValRef
app_Bindings::s --> s_ThunkRef

x_ValRef::val --> 3_IntVal
f_ValRef::val --> f_ProcVal
p_ValRef::val --> 5_IntVal
r_ValRef::val --> addX_ProcVal

let_EnvNode <-- s_ThunkRef::env
init_EnvNode <-- f_ProcVal::env
let_EnvNode <-- addX_ProcVal::env

@enduml
```
