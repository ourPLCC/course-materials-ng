* Is there any reason to prefer SET over REF semantics, where parameters only
  copy the value rather than the reference?

SET is less surprising and so is usually preferred. This is probably why most
modern languages implement pass-by-value. REF is slightly more effeicient as
changes to the variable are immediately reflected in the calling environment
without having to have an additional assignment. This is a good argument for a
langauge like C++ to implement pass-by-reference, as it is designed for
implementing systems that need to run close to the metal and be as efficient as
possible (e.g., embedded systems, real-time systems, high performance
computing, graphics intensive application (yes, including games)).

* On Slide 3a.17, it's demonstrated that only variables can use reference
  semantics and other expressions use value semantics. Would there be a way to
  implement a check to see if an expression doesn't change the value of a
  variable (such as +(x, 0)), to just use call by reference semantics anyways?
  Could we change one expression to another in that manner?

Sure. In fact compilers perform all kinds of optimizations by statically
analyzing code for certain properties, and then exploiting this additional
information; exactly as you are suggesting!

* I'm confused on the difference between call-by-value and call-by-reference

In call-by-value, formals are bound to a new reference (a new memory cell) and
the value of the actual parameter is copied into that reference. In
call-by-reference, when the actual is a variable, the formal is bound to that
variables reference.

* It's very interesting where we're going from here, where V0-V6 were building
  on top of eachother, and now we've come to a divergence point.

Code written for V6 will behave the same on SET. So from this perspective
SET is still an extension of V6 in the same way V6 is an extension of V5;
the new language is backwards compatible with the previous language.

However, REF is not backwards compatible with SET. A program written in SET
may behave differently in REF. The same will be true for NAME, and NEED.

* We briefly talked about dynamic scoping, but it seems like static scoping is
  by far the superior choice in most every language. I wonder if pass-by-value
  is relatively universal as well. From the languages I've used, it seems like
  it, but I don't have enough experience in enough languages to tell.

Yes. static scoping and pass-by-value are widely implemented in modern
languages. They tend to make code easier to understand and less brittle.

* In one particular part of the reading it compared sets to pointers in
  programming. Could you explain what characteristics are similar and what are
  different in more depth.

A reference is an address to a memory location that has been reserved to store
a value. We can use a reference to read or write a value to the memory location
it refers to.

The term pointer gained popularity with C. In C, a pointer is a VALUE. These
values are memory addresses. Since pointers are values, they can be stored
in variables (i.e., in references). C provides operators for dereference these
values to return the value stored in memory at that address, and to set the
value store in memory at that address. C also provides operators that return
the address of a variable's reference.

```c
void main() {
	int x = 3;	// Variable x is bound to memory that stores an int
			// an int, initialized to 3.

	int* y = &x;	// Variable y is bound to memory that stores a pointer
			// (an address) to memory that stores an int,
			// initialized to the address of x's memory.

	*y = 4;		// Use the address value in y as an l-value, and store
			// 4 in that location of memory; thus changing x's value.

	foo(&x);	// Pass the address of x's memory.
}

void foo(int* xp) {	// Variable xp is bound to memory that stores a pointer
			// to memory that stores an int. In the call to foo
			// above, the address of x's memory is stored in xp's
			// memory.

	*xp = *xp + 1;  // Dereference the address in xp and read the value
			// at that location in memory, add 1, use the the
			// address value in xp using it as an l-value and store
			// the result in that location of memory.
	
}

```


