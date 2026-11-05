## REF

"During `.p(x)`" here and in `diagrams-set.md` form the call-by-value versus
call-by-reference pair, so they could replace the chapter's two conceptual figures.

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
app_Bindings::t --> x_ValRef

x_ValRef::val --> 3_IntVal
p_ValRef::val --> p_ProcVal

init_EnvNode <-- p_ProcVal::env

@enduml
```

### During `.p(+(x, 0))`

The "L-value versus non-L-value" program. `+(x, 0)` is not a variable, so `t`
gets a new reference holding a new `IntVal`. Two separate `IntVal`s hold `3`.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let
  x = 3
  p = proc(t) set t = add1(t)  % here
in
  { .p(+(x, 0)) ; x }
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

  map ":IntVal" as 3b_IntVal {
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

let_Bindings::x --> x_ValRef
let_Bindings::p --> p_ValRef
app_Bindings::t --> t_ValRef

x_ValRef::val --> 3_IntVal
p_ValRef::val --> p_ProcVal
t_ValRef::val --> 3b_IntVal

init_EnvNode <-- p_ProcVal::env

@enduml
```
