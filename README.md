# C-THREAD:
## A limited implementation of threads using call/cc

This is a quick and dirty guile library that allows programs to manually switch between saved program states. Using the library strongly resembles using threads (with manual scheduling), but the implementation does not invoke the os at all. Everything is implemented using call/cc.

Here's how to use it:
 * First, add some cthreads to a global thread queue.
 * Then, invoke a context switch to pass control to the next cthread in line.

That's pretty much all this library does. I made it because it's cool AF and nobody can stop me.

API Reference:

```scheme
(use-modules (cthread))```

To add a new thread to the global thread queue, use `add-cthread`.

===
[procedure]
  add-cthread *proc* . *args*

Register a new cthread to the front of the calling process's global cthread queue. The cthread has a starting point of *proc*, which will be called with the argument list *args*.

If, while *proc*'s cthread is executing, *proc* returns, then the cthread will execute (remove-cthread).

This procedure returns immediately. It's return value is unspecified.
===

Once you've registered some cthreads, you can invoke a context switch to pass control to them.

===
[procedure]
  next-cthread

Save the calling cthread's execution state to the back of the process's global cthread queue, then pop a cthread from the event queue and pass control to it. The return value of this procedure is unspecified.
===

You can unregister a thread and have it ceace execution:

===
[procedure]
  remove-cthread

Pass control to the next cthread popped from the cthread queue. Do this without saving the execution state of the calling cthread. The calling cthread is lost.

If the cthread queue is empty, terminate the calling process.

This procedure does not return.
===

Finally, you can check the size of the queue:

===
[procedure]
  num-cthreads => n
  n := a positive integer

Return the number of cthreads currently in the cthread queue.
===
