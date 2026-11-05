## V4

New example: a closure over a `let`, before references exist. The program is the
static-scoping example from the V4 chapter. The call extends the closure's
captured environment (`outer:EnvNode`), not the calling environment (`inner:EnvNode`), so
`x` resolves to `3`. `init` and `empty` are left out to reduce crowding, and the
chain continues past `outer:EnvNode`.

### During `.f()`

```plantuml
@startuml
skinparam fileFontName monospaced

file source [
let               % outer
  x = 3
in
  let             % middle
    f = proc() x  % here
  in
    let           % inner
      x = 5
    in
      .f()        % app
]

'Environments
together {

  map "outer:EnvNode" as outer_EnvNode {
  }

  map "middle:EnvNode" as middle_EnvNode {
  }

  map "inner:EnvNode" as inner_EnvNode {
  }

  map "app:EnvNode" as app_EnvNode {
  }

}

'Bindings
together {
  map "outer:Bindings" as outer_Bindings {
    x =>
  }

  map "middle:Bindings" as middle_Bindings {
    f =>
  }

  map "inner:Bindings" as inner_Bindings {
    x =>
  }

  map "app:Bindings" as app_Bindings {
  }
}

'Values
together {
  map ":IntVal" as 3_IntVal {
    val => 3
  }

  map "f:ProcVal" as f_ProcVal {
    formals =>
    body => x
    env =>
  }

  map ":IntVal" as 5_IntVal {
    val => 5
  }
}

'Edges

source ..> app_EnvNode : here

app_EnvNode -> outer_EnvNode
inner_EnvNode -> middle_EnvNode
middle_EnvNode -> outer_EnvNode

outer_EnvNode --> outer_Bindings
middle_EnvNode --> middle_Bindings
inner_EnvNode --> inner_Bindings
app_EnvNode --> app_Bindings

outer_Bindings::x --> 3_IntVal
middle_Bindings::f --> f_ProcVal
inner_Bindings::x --> 5_IntVal

outer_EnvNode <-- f_ProcVal::env

@enduml
```
