* Having some confusion over the difference between let and set, which gets priority, that kind of thing.

`let` extends an environment with new bindings and evaluates its body
in the new environment.

`set` updates the value in the ValRef bound to the given symbol.

Neither gets "priority". It all depends on where the expressions appear.
Thinking through these examples might help.

```
let
    x = 3
in {
    set x = 5 ;
    x
}

let
    x = 3
in {
    set x = {
        let x = 5
        in {
            set x = 8 % updates inner x to 8
        } % evaluates to 8
    } % updates outer x to 8 and evaluates to 8
} % evaluates to 8
```



* I was confused on slide 3a.12.

AppExp, Let, and LetRec create new ValRefs for each binding.
So when we pass arguments into a proc, new ValRefs are created for
each parameter, and the values are placed into the new ValRefs.

So a `set` in the body of a proc that modifies a parameter changes
the value in the ValRef associated with the local parameter. This does
not modify the ValRef in the calling environment.

* Are references the same as pointers or is there a difference between them?

Most people use the terms interchangeably. If we are in the context of C++
they are related, but different. In this context, a pointer is a value.
So in our language, imagine you have a new Val type PointerVal. You would
then add some syntax to the language that allows you to write expressions
to express these values. In C++, the following expression expresses the
address of the variable associated with x.

```c++
&x
```

In C++, a reference variable is a variable that is bound to the same memory
as another variable; it is an alias. When you refer to one variable, you
are referring to another too, because they are the same.

```c++
int  y = 3;
int& x = y;
x = 5;  // changes y as well, because they are the same variable.
```

This is more like what we are talking about in our language. Instead of
having an expressed value that is a memory address, we have a denoted value
(the ValRef) that represents the location in memory where a value is stored.

* I am interested in how we are moving forward, based on the new naming convention. I am guessing that these are splintering off into different directions / paradigms from V6 from this point forward, or are they continuing to add onto V6 just with a new name?

SET extends V6 and REF extends SET. The relationships should become clear
as we study their semantics.
