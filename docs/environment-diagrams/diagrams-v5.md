## V5

### Before evaluating the right-hand side of `x`

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
letrec
  x = 5  % here
  f = proc(t) *(t, x)
in
  .f(42)
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "letrec:EnvNode" as letrec_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
  }

  map "letrec:Bindings" as letrec_Bindings {
  }
}

'Edges

source ..> letrec_EnvNode : here

letrec_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
letrec_EnvNode --> letrec_Bindings

@enduml
```

### Before `.f(42)`

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
letrec
  x = 5
  f = proc(t) *(t, x)
in
  .f(42)  % here
]

'Environments
together {

  map "empty:EnvNull" as empty_EnvNull {
  }

  map "init:EnvNode" as init_EnvNode {
  }

  map "letrec:EnvNode" as letrec_EnvNode {
  }

}

'Bindings
together {
  map "init:Bindings" as init_Bindings {
  }

  map "letrec:Bindings" as letrec_Bindings {
    x =>
    f =>
  }
}

'Values
together {
  map ":IntVal" as 5_IntVal {
    val => 5
  }

  map "f:ProcVal" as f_ProcVal {
    formals => t
    body => ~*(t, x)
    env =>
  }
}

'Edges

source ..> letrec_EnvNode : here

letrec_EnvNode -> init_EnvNode
init_EnvNode -> empty_EnvNull

init_EnvNode --> init_Bindings
letrec_EnvNode --> letrec_Bindings

letrec_Bindings::x --> 5_IntVal
letrec_Bindings::f --> f_ProcVal

letrec_EnvNode <-[norank]- f_ProcVal::env

@enduml
```

### During `.f(42)`

`init` and `empty` are left out to reduce crowding, and the chain continues past
`letrec:EnvNode`.

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
letrec
  x = 5
  f = proc(t) *(t, x)  % here
in
  .f(42)
]

'Environments
together {

  map "letrec:EnvNode" as letrec_EnvNode {
  }

  map "app:EnvNode" as app_EnvNode {
  }

}

'Bindings
together {
  map "letrec:Bindings" as letrec_Bindings {
    x =>
    f =>
  }

  map "app:Bindings" as app_Bindings {
    t =>
  }
}

'Values
together {
  map ":IntVal" as 5_IntVal {
    val => 5
  }

  map "f:ProcVal" as f_ProcVal {
    formals => t
    body => ~*(t, x)
    env =>
  }

  map ":IntVal" as 42_IntVal {
    val => 42
  }
}

'Edges

source ..> app_EnvNode : here

app_EnvNode -> letrec_EnvNode

letrec_EnvNode --> letrec_Bindings
app_EnvNode --> app_Bindings

letrec_Bindings::x --> 5_IntVal
letrec_Bindings::f --> f_ProcVal
app_Bindings::t --> 42_IntVal

letrec_EnvNode <-- f_ProcVal::env

@enduml
```
