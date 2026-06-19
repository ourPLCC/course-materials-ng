# Q&A for NAME

* Can you have nested set statements like you can have nested let statements
  and if so are they something that is used often?

Yes. Review the slide for SET. There is an example of this. Here is one off
the top of my head.

	set x = set y = set z = 4

The parser sees this as a SetExp with a VAR of x and an expression. That
expression is a SetExp with a VAR of y and an expression. That expression
is a SetExp with a VAR of z and an express. That expression is a LitExp 4.
When we evaluate the outer SetExp, it first evaluates its expression.
That expression is a SetExp, and when it is evaluated it first evaluates
its expression. That expression is also a SetExp, and when it is evaluated
it evaluates its expression, which is 4, and updates the value in the reference
bound to z and returns that same value (4) as the result of evaluating
that SetExp. Poping back up to the caller (the middle SetExp) it updates
y to 4 and returns 4. The outer SetExp then updates x to 4 and returns 4.

We can use { } to visualize the nested structure of the example.

	set x = {set y = {set z = {4}}}

* I feel like the languages look similar  but are different at the same time.

That's the difference between syntax (the look) and semantics (the meaning).

* Pass-by-name is really confusing. I think it would be helpful to build an
  environment diagram from scratch because the diagram on slide 3a.31 is super
  confusing to decipher. 

Good idea.

* Confused on how to write a set being passed into .f

Observe:

	.f(set x = 4)

* If possible, it would be nice to go over a few instances of call-by-name in
  nature to see why it would be used beyond the examples given within NAME.

The "while loop" example in the slides is probably the best one. This now let's
us write procs that can evaluate passed expressions in the calling environment.
Before pass-by-name, we could modify passed variables through call-by-ref, but
that's it. Now the caller can pass expressions that evaluate in the calling
environment.

* Is pass by name achieving something similar to dynamic scoping? For example,
  on slide 3a.25, we get 7 because x gets set to 2 and then we add 5 to it.
  Would it be wrong to think of that is similar to dynamic scoping, but in a
  more contained sense? Or would we consider that closer to static scoping?

I agree that there is a connection between pass-by-name and dynamic scoping.
The passed expression is like a proc that has no parameters, and that proc
evaluates in the calling environment.

Perhaps interstingly, we can simulate pass-by-name as follows:

	let
		f = proc(t) { .t() ; .t() ; .t() }
		x = 5
	in
		.f( proc() set x = add1(x) )

For the proc defined in the `in`, its defining environment IS `f`'s calling
environment. So when we apply the proc inside the proc bound to f, its
expression is evaluated in `f`'s calling environment.

Notice this is a simulation of pass-by-name, but isn't pass-by-name. Notice
how we have to apply the passed proc.

* No questions. Pass my name semantics seems like it closely mimics variable
  behavior in programs like Java.

Hmm... I'm not seeing it. Maybe you are thinking about how objects carry
state, and every function in Java is really a method bound to an object
(or a class), and so that method evaluates within the environment of that
object (or class). Hang on to that thought. We're almost there.


